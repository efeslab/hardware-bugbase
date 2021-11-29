#include <iostream>
#include <string>
#include <fstream>
#include <cctype>
#include <sstream>
#include <cassert>
#include <stdlib.h>
#include <time.h>
#include <queue>
#include "ccip_test_pkt.h"
using namespace std;

vector<string> string_split(string &str, char delimiter) {
    string tmp = "";
    vector<string> r;
    for (int i = 0; i < str.length(); i++) {
        if (str[i] == delimiter) {
            r.push_back(tmp);
            tmp = "";
        } else {
            tmp += str[i];
        }
    }
    if (tmp != "")
        r.push_back(tmp);

    return r;
}

void parse_config(string &config,
        priority_queue<pkt_entry*, vector<pkt_entry*>, pkt_entry_ptr_compare> &control,
        priority_queue<pkt_entry*, vector<pkt_entry*>, pkt_entry_ptr_compare> &c0rx_issue,
        priority_queue<pkt_entry*, vector<pkt_entry*>, pkt_entry_ptr_compare> &c1rx_issue,
        vector<pkt_entry*> &c0tx_listen,
        vector<pkt_entry*> &c1tx_listen,
        vector<pkt_entry*> &c2tx_listen) {

    ifstream ifs(config);
    string line;

    while (getline(ifs, line)) {
        vector<string> ll = string_split(line, ' ');
        string &ts = ll[0];
        string &ty = ll[1];

        if (isdigit(ts[0])) {
            uint64_t timestamp = stoll(ts);
            if (ty == "softreset") {
                pkt_soft_reset *ent = new pkt_soft_reset;
                ent->timestamp = stoll(ts);

                vector<string> kv = string_split(ll[2], '=');
                string &key = kv[0];
                string &val = kv[1];
                assert(key == "len");
                ent->length = stoll(val);

                control.push(ent);

            } else if (ty == "almfull") {
                pkt_almfull *ent = new pkt_almfull;
                ent->timestamp = stoll(ts);

                for (int i = 2; i < ll.size(); i++) {
                    vector<string> kv = string_split(ll[i], '=');
                    string &key = kv[0];
                    string &val = kv[1];

                    if (key == "ch") {
                        ent->channel = stoll(val);
                    } else if (key == "len") {
                        ent->length = stoll(val);
                    } else {
                        cerr << "unsupported argument" << endl;
                        abort();
                    }
                }

                control.push(ent);

            } else if (ty == "mmio_rd") {
                pkt_mmio_rd *ent = new pkt_mmio_rd;
                ent->timestamp = stoll(ts);

                ent->hdr.tid = 0;
                ent->hdr.rsvd = 0;
                ent->hdr.length = 1; // only support 8B read
                ent->hdr.address = 0;

                for (int i = 2; i < ll.size(); i++) {
                    vector<string> kv = string_split(ll[i], '=');
                    string &key = kv[0];
                    string &val = kv[1];

                    if (key == "tid") {
                        stringstream ss;
                        uint64_t tid;
                        ss << std::hex << val;
                        ss >> tid;
                        ent->hdr.tid = tid;
                    } else if (key == "addr") {
                        stringstream ss;
                        uint64_t address;
                        ss << std::hex << val;
                        ss >> address;
                        ent->hdr.address = address;
                    } else if (key == "expval") {
                        stringstream ss;
                        uint64_t expval;
                        ss << std::hex << val;
                        ss >> expval;
                        ent->expected_value = expval;
                    } else {
                        cerr << "unsupported argument" << endl;
                        abort();
                    }
                }

                c0rx_issue.push(ent);
            
            } else if (ty == "mmio_wr") {
                pkt_mmio_wr *ent = new pkt_mmio_wr;
                ent->timestamp = stoll(ts);

                ent->hdr.tid = 0;
                ent->hdr.rsvd = 0;
                ent->hdr.length = 1; // only support 8B write
                ent->hdr.address = 0;

                for (int i = 2; i < ll.size(); i++) {
                    vector<string> kv = string_split(ll[i], '=');
                    string &key = kv[0];
                    string &val = kv[1];

                    if (key == "tid") {
                        stringstream ss;
                        uint64_t tid;
                        ss << std::hex << val;
                        ss >> tid;
                        ent->hdr.tid = tid;
                    } else if (key == "addr") {
                        stringstream ss;
                        uint64_t address;
                        ss << std::hex << val;
                        ss >> address;
                        ent->hdr.address = address;
                    } else if (key == "val") {
                        stringstream ss;
                        uint64_t value;
                        ss << std::hex << val;
                        ss >> value;
                        ent->value = value;
                    } else {
                        cerr << "unsupported argument" << endl;
                        abort();
                    }
                }

                c0rx_issue.push(ent);
            }
        } else if (ts == "expect") {
            if (ty == "mem_rd") {
                pkt_mem_rd *ent = new pkt_mem_rd;

                ent->hdr.mdata = 0;
                ent->hdr.resp_type = eRSP_RDLINE; // only support RELINE
                ent->hdr.cl_num = eCL_LEN_1;
                ent->hdr.rsvd0 = 0;
                ent->hdr.hit_miss = 0;
                ent->hdr.rsvd1 = 0;
                ent->hdr.vc_used = eVC_VL0;

                for (int i = 2; i < ll.size(); i++) {
                    vector<string> kv = string_split(ll[i], '=');
                    string &key = kv[0];
                    string &val = kv[1];

                    if (key == "addr") {
                        stringstream ss;
                        uint64_t address;
                        ss << std::hex << val;
                        ss >> address;
                        ent->expected_address = address;
                    } else if (key == "timer") {
                        vector<string> md = string_split(val, ',');
                        string &mod = md[0];
                        uint64_t ts = stoll(md[1]);
                        if (mod == "const") {
                            ent->timer_kind = pkt_entry::PKT_TIMER_CONST;
                            ent->timestamp = ts;
                        } else if (mod == "delay") {
                            ent->timer_kind = pkt_entry::PKT_TIMER_DELAY;
                            ent->timestamp = ts;
                        } else {
                            cerr << "unsupported argument" << endl;
                            abort();
                        }
                    } else if (key == "val") {
                        if (val == "any") {
                            for (int k = 0; k < 8; k++) {
                                ent->value[k] = rand();
                            }
                        } else {
                            assert(val.length() == 128);
                            string val_split[8];
                            for (int k = 0; k < 8; k++) {
                                string val64bit = val.substr(k*16, 16);
                                stringstream ss;
                                ss << std::hex << val64bit;
                                ss >> ent->value[7-k];
                            }
                        }
                    } else {
                        cerr << "unsupported argument" << endl;
                        abort();
                    }
                }

                c0tx_listen.push_back(ent);

            } else if (ty == "mem_wr") {
                pkt_mem_wr *ent = new pkt_mem_wr;

                ent->hdr.mdata = 0;
                ent->hdr.resp_type = eRSP_WRLINE;
                ent->hdr.cl_num = eCL_LEN_1;
                ent->hdr.rsvd0 = 0;
                ent->hdr.format = 0;
                ent->hdr.hit_miss = 0;
                ent->hdr.rsvd1 = 0;
                ent->hdr.vc_used = eVC_VL0;

                for (int i = 2; i < ll.size(); i++) {
                    vector<string> kv = string_split(ll[i], '=');
                    string &key = kv[0];
                    string &val = kv[1];

                    if (key == "addr") {
                        stringstream ss;
                        uint64_t address;
                        ss << std::hex << val;
                        ss >> address;
                        ent->expected_address = address;
                    } else if (key == "timer") {
                        vector<string> md = string_split(val, ',');
                        string &mod = md[0];
                        uint64_t ts = stoll(md[1]);
                        if (mod == "const") {
                            ent->timer_kind = pkt_entry::PKT_TIMER_CONST;
                            ent->timestamp = ts;
                        } else if (mod == "delay") {
                            ent->timer_kind = pkt_entry::PKT_TIMER_DELAY;
                            ent->timestamp = ts;
                        } else {
                            cerr << "unsupported argument" << endl;
                            abort();
                        }
                    } else {
                        cerr << "unsupported argument" << endl;
                        abort();
                    }
                }

                c1tx_listen.push_back(ent);

            } else if (ty == "fence") {
                pkt_fence *ent = new pkt_fence;

                ent->hdr.mdata = 0;
                ent->hdr.resp_type = eRSP_WRFENCE;
                ent->hdr.rsvd0 = 0;

                c1tx_listen.push_back(ent);

            } else {
                cerr << "unsupported argument" << endl;
                abort();
            }
        }
    }
}

