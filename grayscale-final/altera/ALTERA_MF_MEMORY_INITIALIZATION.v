// Created by altera_lib_mf.pl from altera_mf.v

// BEGINNING OF MODULE
//`timescale 1 ps / 1 ps

`define TRUE 1
`define FALSE 0
`define NULL 0
`define EOF -1
`define MAX_BUFFER_SZ   2048
`define MAX_NAME_SZ     256
`define MAX_WIDTH       1024
`define COLON           ":"
`define DOT             "."
`define NEWLINE         "\n"
`define CARRIAGE_RETURN  8'h0D
`define SPACE           " "
`define TAB             "\t"
`define OPEN_BRACKET    "["
`define CLOSE_BRACKET   "]"
`define OFFSET          9
`define H10             8'h10
`define H10000          20'h10000
`define AWORD           8
`define MASK15          32'h000000FF
`define EXT_STR         "ver"
`define PERCENT         "%"
`define MINUS           "-"
`define SEMICOLON       ";"
`define EQUAL           "="

// MODULE DECLARATION
/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module ALTERA_MF_MEMORY_INITIALIZATION;

/****************************************************************/
/* convert uppercase character values to lowercase.             */
/****************************************************************/
function [8:1] tolower;
    input [8:1] given_character;
    reg [8:1] conv_char;

begin
    if ((given_character >= 65) && (given_character <= 90)) // ASCII number of 'A' is 65, 'Z' is 90
    begin
        conv_char = given_character + 32; // 32 is the difference in the position of 'A' and 'a' in the ASCII char set
        tolower = conv_char;
    end
    else
        tolower = given_character;
end
endfunction


/****************************************************************/
/* function for ecc parity                                      */
/****************************************************************/
function [7:0] ecc_parity;
    input [7:0] i_eccencparity;
    integer pointer,pointer_max,pointer_min,flag_err,flag,flag_double,flag_triple,flag_single,flag_no_err ,flag_uncorr;
    integer n;
    integer err,found ;
    integer found_2;
begin
    pointer=0;
    pointer_max=0;
    pointer_min=0;
    flag_err=0;
    flag=0;
    flag_double=0;
    flag_triple=0;
    flag_single=0;
    flag_no_err =0;
    flag_uncorr=0;
    err=0;
    found=0;
    found_2=0;
		for (n = 0 ; n<8 ;n=n+1)
		begin
			if (i_eccencparity[n] == 'b1 && found == 0 )
			begin
				pointer_min = n;
				found = 1;
			end
		end

		for (n = 7 ; n>=0 ;n=n-1)
		begin
			if (i_eccencparity[n] == 'b1 && found_2 == 0)
			begin
				pointer_max = n;
				found_2 = 1;
			end
		end

		pointer = pointer_max - pointer_min ;

		if (i_eccencparity == 8'h0)
		begin
			flag_no_err =1;
			ecc_parity = 2'b00;
		end

		else if (pointer == 0)
		begin
			flag_single =1;
			ecc_parity = 2'b10;
		end

		else if (pointer == 1)
		begin
			flag_double =1;
			ecc_parity = 2'b10;
		end

		else if (pointer == 2)
		begin
			flag_triple =1;
			ecc_parity = 2'b10;
		end

		else if (pointer > 2)
		begin
			flag_uncorr =1;
			ecc_parity = 2'b11;
		end
end//function
endfunction

/****************************************************************/
/* Read in Altera-mif format data to verilog format data.       */
/****************************************************************/
task convert_mif2ver;
    input[`MAX_NAME_SZ*8 : 1] in_file;
    input width;
    output [`MAX_NAME_SZ*8 : 1] out_file;
    reg [`MAX_NAME_SZ*8 : 1] in_file;
    reg [`MAX_NAME_SZ*8 : 1] out_file;
    reg [`MAX_NAME_SZ*8 : 1] buffer;
    reg [`MAX_WIDTH : 0] memory_data1, memory_data2;
    reg [8 : 1] c;
    reg [3 : 0] hex, tmp_char;
    reg [24 : 1] address_radix, data_radix;
    reg get_width;
    reg get_depth;
    reg get_data_radix;
    reg get_address_radix;
    reg width_found;
    reg depth_found;
    reg data_radix_found;
    reg address_radix_found;
    reg get_address_data_pairs;
    reg get_address;
    reg get_data;
    reg display_address;
    reg invalid_address;
    reg get_start_address;
    reg get_end_address;
    reg done;
    reg error_status;
    reg first_rec;
    reg last_rec;

    integer width;
    integer memory_width, memory_depth;
    integer value;
    integer ifp, ofp, r, r2;
    integer i, j, k, m, n;
    integer negative;
    integer off_addr, nn, address, tt, cc, aah, aal, dd, sum ;
    integer start_address, end_address;
    integer line_no;
    integer character_count;
    integer comment_with_percent_found;
    integer comment_with_double_minus_found;

begin
        done = `FALSE;
        error_status = `FALSE;
        first_rec = `FALSE;
        last_rec = `FALSE;
        comment_with_percent_found = `FALSE;
        comment_with_double_minus_found = `FALSE;

        off_addr= 0;
        nn= 0;
        address = 0;
        start_address = 0;
        end_address = 0;
        tt= 0;
        cc= 0;
        aah= 0;
        aal= 0;
        dd= 0;
        sum = 0;
        line_no = 1;
        c = 0;
        hex = 0;
        value = 0;
        buffer = "";
        character_count = 0;
        memory_width = 0;
        memory_depth = 0;
        memory_data1 = {(`MAX_WIDTH+1) {1'b0}};
        memory_data2 = {(`MAX_WIDTH+1) {1'b0}};
        address_radix = "hex";
        data_radix = "hex";
        get_width = `FALSE;
        get_depth = `FALSE;
        get_data_radix = `FALSE;
        get_address_radix = `FALSE;
        width_found = `FALSE;
        depth_found = `FALSE;
        data_radix_found = `FALSE;
        address_radix_found = `FALSE;
        get_address_data_pairs = `FALSE;
        display_address = `FALSE;
        invalid_address = `FALSE;
        get_start_address = `FALSE;
        get_end_address = `FALSE;

        if((in_file[4*8 : 1] == ".dat") || (in_file[4*8 : 1] == ".DAT"))
            out_file = in_file;
        else
        begin
            ifp = $fopen(in_file, "r");

            if (ifp == `NULL)
            begin
                $display("ERROR: cannot read %0s.", in_file);
                done = `TRUE;
            end

            out_file = in_file;

            if((out_file[4*8 : 1] == ".mif") || (out_file[4*8 : 1] == ".MIF"))
                out_file[3*8 : 1] = `EXT_STR;
            else
            begin
                $display("ERROR: Invalid input file name %0s. Expecting file with .mif extension and Altera-mif data format.", in_file);
                done = `TRUE;
            end

            if (!done)
            begin
                ofp = $fopen(out_file, "w");

                if (ofp == `NULL)
                begin
                    $display("ERROR : cannot write %0s.", out_file);
                    done = `TRUE;
                end
            end

            while((!done) && (!error_status))
            begin : READER

                r = $fgetc(ifp);

                if (r == `EOF)
                begin
                // to do : add more checking on whether a particular assigment(width, depth, memory/address) are mising
                    if(!first_rec)
                    begin
                        error_status = `TRUE;
                        $display("WARNING: %0s, Intel-hex data file is empty.", in_file);
                        $display ("Time: %0t  Instance: %m", $time);
                    end
                    else if (!get_address_data_pairs)
                    begin
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Missing `content begin` statement.", in_file, line_no);
                    end
                    else if(!last_rec)
                    begin
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Missing `end` statement.", in_file, line_no);
                    end
                    done = `TRUE;
                end
                else if ((r == `NEWLINE) || (r == `CARRIAGE_RETURN))
                begin
                    if ((buffer == "contentbegin") && (get_address_data_pairs == `FALSE))
                    begin
                        get_address_data_pairs = `TRUE;
                        get_address = `TRUE;
                        buffer = "";
                    end
                    else if (buffer == "content")
                    begin
                        // continue to next character
                    end
                    else
                    if (buffer != "")
                    begin
                        // found invalid syntax in the particular line.
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Invalid Altera-mif record.", in_file, line_no);
                        disable READER;
                    end
                    line_no = line_no +1;

                end
                else if ((r == `SPACE) || (r == `TAB))
                begin
                    // continue to next character;
                end
                else if (r == `PERCENT)
                begin
                    // Ignore all the characters which which is part of comment.
                    r = $fgetc(ifp);

                    while ((r != `PERCENT) && (r != `NEWLINE) && (r != `CARRIAGE_RETURN))
                    begin
                        r = $fgetc(ifp);
                    end

                    if ((r == `NEWLINE) || (r == `CARRIAGE_RETURN))
                    begin
                        line_no = line_no +1;

                        if ((buffer == "contentbegin") && (get_address_data_pairs == `FALSE))
                        begin
                            get_address_data_pairs = `TRUE;
                            get_address = `TRUE;
                            buffer = "";
                        end
                    end
                end
                else if (r == `MINUS)
                begin
                    if(get_data == `TRUE && data_radix == "dec")begin
                        negative = 1;
                    end
                    else begin
                        r = $fgetc(ifp);
                        if (r == `MINUS)
                        begin
                            // Ignore all the characters which which is part of comment.
                            r = $fgetc(ifp);

                            while ((r != `NEWLINE) && (r != `CARRIAGE_RETURN))
                            begin
                                r = $fgetc(ifp);

                            end

                            if ((r == `NEWLINE) || (r == `CARRIAGE_RETURN))
                            begin
                                line_no = line_no +1;

                                if ((buffer == "contentbegin") && (get_address_data_pairs == `FALSE))
                                begin
                                    get_address_data_pairs = `TRUE;
                                    get_address = `TRUE;
                                    buffer = "";
                                end
                            end
                        end
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid Altera-mif record.", in_file, line_no);
                            done = `TRUE;
                            disable READER;
                        end
                    end
                end
                else if (r == `EQUAL)
                begin
                    if (buffer == "width")
                    begin
                        if (width_found == `FALSE)
                        begin
                            get_width = `TRUE;
                            buffer = "";
                        end
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Width has already been specified once.", in_file, line_no);
                        end
                    end
                    else if (buffer == "depth")
                    begin
                        get_depth = `TRUE;
                        buffer = "";
                    end
                    else if (buffer == "data_radix")
                    begin
                        get_data_radix = `TRUE;
                        buffer = "";
                    end
                    else if (buffer == "address_radix")
                    begin
                        get_address_radix = `TRUE;
                        buffer = "";
                    end
                    else
                    begin
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Unknown setting (%0s).", in_file, line_no, buffer);
                    end
                end
                else if (r == `COLON)
                begin
                    if (!get_address_data_pairs)
                    begin
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Missing `content begin` statement.", in_file, line_no);
                    end
                    else if (invalid_address == `TRUE)
                    begin
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Invalid data record.", in_file, line_no);
                    end
                    begin
                        get_address = `FALSE;
                        get_data = `TRUE;
                        display_address = `TRUE;
                        negative = 0;
                    end
                end
                else if (r == `DOT)
                begin
                    r = $fgetc(ifp);
                    if (r == `DOT)
                    begin
                        if (get_start_address == `TRUE)
                        begin
                            start_address = address;
                            address = 0;
                            get_start_address = `FALSE;
                            get_end_address = `TRUE;
                        end
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid Altera-mif record.", in_file, line_no);
                            done = `TRUE;
                            disable READER;
                        end
                    end
                    else
                    begin
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Invalid Altera-mif record.", in_file, line_no);
                        done = `TRUE;
                        disable READER;
                    end
                end
                else if (r == `OPEN_BRACKET)
                begin
                    get_start_address = `TRUE;
                end
                else if (r == `CLOSE_BRACKET)
                begin
                    if (get_end_address == `TRUE)
                    begin
                        end_address = address;
                        address = 0;
                        get_end_address = `FALSE;
                    end
                    else
                    begin
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Invalid Altera-mif record.", in_file, line_no);
                        done = `TRUE;
                        disable READER;
                    end
                end
                else if (r == `SEMICOLON)
                begin
                    if (get_width == `TRUE)
                    begin
                        width_found = `TRUE;
                        memory_width = value;
                        value = 0;
                        get_width = `FALSE;
                    end
                    else if (get_depth == `TRUE)
                    begin
                        depth_found = `TRUE;
                        memory_depth = value;
                        value = 0;
                        get_depth = `FALSE;
                    end
                    else if (get_data_radix == `TRUE)
                    begin
                        data_radix_found = `TRUE;
                        get_data_radix = `FALSE;

                        if ((buffer == "bin") || (buffer == "oct") || (buffer == "dec") || (buffer == "uns") ||
                            (buffer == "hex"))
                        begin
                            data_radix = buffer[24 : 1];
                        end
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid assignment (%0s) to data_radix.", in_file, line_no, buffer);
                        end
                        buffer = "";
                    end
                    else if (get_address_radix == `TRUE)
                    begin
                        address_radix_found = `TRUE;
                        get_address_radix = `FALSE;

                        if ((buffer == "bin") || (buffer == "oct") || (buffer == "dec") || (buffer == "uns") ||
                            (buffer == "hex"))
                        begin
                            address_radix = buffer[24 : 1];
                        end
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid assignment (%0s) to address radix.", in_file, line_no, buffer);
                        end
                        buffer = "";
                    end
                    else if (buffer == "end")
                    begin
                        if (get_address_data_pairs == `TRUE)
                        begin
                            last_rec = `TRUE;
                            buffer = "";
                        end
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Missing `content begin` statement.", in_file, line_no);
                        end
                    end
                    else if (get_data == `TRUE)
                    begin
                        get_address = `TRUE;
                        get_data = `FALSE;
                        buffer = "";
                        character_count = 0;

                        if (start_address != end_address)
                        begin
                            for (address = start_address; address <= end_address; address = address+1)
                            begin
                                $fdisplay(ofp,"@%0h", address);
                                if (negative == 1) begin
                                    memory_data1 = memory_data1 * -1;
                                end
                                for (i = memory_width -1; i >= 0; i = i-1 )
                                begin
                                    hex[(i % 4)] =  memory_data1[i];

                                    if ((i % 4) == 0)
                                    begin
                                        $fwrite(ofp, "%0h", hex);
                                        hex = 0;
                                    end
                                end

                                $fwrite(ofp, "\n");
                            end
                            start_address = 0;
                            end_address = 0;
                            address = 0;
                            hex = 0;
                            memory_data1 = {(`MAX_WIDTH+1) {1'b0}};
                        end
                        else
                        begin
                            if (display_address == `TRUE)
                            begin
                                $fdisplay(ofp,"@%0h", address);
                                display_address = `FALSE;
                            end

                            if (negative == 1) begin
                                memory_data1 = memory_data1 * -1;
                            end

                            for (i = memory_width -1; i >= 0; i = i-1 )
                            begin
                                hex[(i % 4)] =  memory_data1[i];

                                if ((i % 4) == 0)
                                begin
                                    $fwrite(ofp, "%0h", hex);
                                    hex = 0;
                                end
                            end

                            $fwrite(ofp, "\n");
                            address = 0;
                            hex = 0;
                            memory_data1 = {(`MAX_WIDTH+1) {1'b0}};
                        end
                    end
                    else
                    begin
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Invalid assigment.", in_file, line_no);
                    end
                end
                else if ((get_width == `TRUE) || (get_depth == `TRUE))
                begin
                    if ((r >= "0") && (r <= "9"))
                        value = (value * 10) + (r - 'h30);
                    else
                    begin
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Invalid assignment to width/depth.", in_file, line_no);
                    end
                end
                else if (get_address == `TRUE)
                begin
                    if (address_radix == "hex")
                    begin
                        if ((r >= "0") && (r <= "9"))
                            value = (r - 'h30);
                        else if ((r >= "A") && (r <= "F"))
                            value = 10 + (r - 'h41);
                        else if ((r >= "a") && (r <= "f"))
                            value = 10 + (r - 'h61);
                        else
                        begin
                            invalid_address = `TRUE;
                        end

                        address = (address * 16) + value;
                    end
                    else if ((address_radix == "dec"))
                    begin
                        if ((r >= "0") && (r <= "9"))
                            value = (r - 'h30);
                        else
                        begin
                            invalid_address = `TRUE;
                        end

                        address = (address * 10) + value;
                    end
                    else if (address_radix == "uns")
                    begin
                        if ((r >= "0") && (r <= "9"))
                            value = (r - 'h30);
                        else
                        begin
                            invalid_address = `TRUE;
                        end

                        address = (address * 10) + value;
                    end
                    else if (address_radix == "bin")
                    begin
                        if ((r >= "0") && (r <= "1"))
                            value = (r - 'h30);
                        else
                        begin
                            invalid_address = `TRUE;
                        end

                        address = (address * 2) + value;
                    end
                    else if (address_radix == "oct")
                    begin
                        if ((r >= "0") && (r <= "7"))
                            value = (r - 'h30);
                        else
                        begin
                            invalid_address = `TRUE;
                        end

                        address = (address * 8) + value;
                    end

                    if ((r >= 65) && (r <= 90))
                        c = tolower(r);
                    else
                        c = r;

                    {tmp_char,buffer} = {buffer, c};
                end
                else if (get_data == `TRUE)
                begin
                    character_count = character_count +1;

                    if (data_radix == "hex")
                    begin
                        if ((r >= "0") && (r <= "9"))
                            value = (r - 'h30);
                        else if ((r >= "A") && (r <= "F"))
                            value = 10 + (r - 'h41);
                        else if ((r >= "a") && (r <= "f"))
                            value = 10 + (r - 'h61);
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid data record.", in_file, line_no);
                            done = `TRUE;
                            disable READER;
                        end

                        memory_data1 = (memory_data1 * 16) + value;
                    end
                    else if ((data_radix == "dec"))
                    begin
                        if ((r >= "0") && (r <= "9"))
                            value = (r - 'h30);
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid data record.", in_file, line_no);
                            done = `TRUE;
                            disable READER;
                        end

                        memory_data1 = (memory_data1 * 10) + value;
                    end
                    else if (data_radix == "uns")
                    begin
                        if ((r >= "0") && (r <= "9"))
                            value = (r - 'h30);
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid data record.", in_file, line_no);
                            done = `TRUE;
                            disable READER;
                        end

                        memory_data1 = (memory_data1 * 10) + value;
                    end
                    else if (data_radix == "bin")
                    begin
                        if ((r >= "0") && (r <= "1"))
                            value = (r - 'h30);
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid data record.", in_file, line_no);
                            done = `TRUE;
                            disable READER;
                        end

                        memory_data1 = (memory_data1 * 2) + value;
                    end
                    else if (data_radix == "oct")
                    begin
                        if ((r >= "0") && (r <= "7"))
                            value = (r - 'h30);
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid data record.", in_file, line_no);
                            done = `TRUE;
                            disable READER;
                        end

                        memory_data1 = (memory_data1 * 8) + value;
                    end
                end
                else
                begin
                    first_rec = `TRUE;

                    if ((r >= 65) && (r <= 90))
                        c = tolower(r);
                    else
                        c = r;

                    {tmp_char,buffer} = {buffer, c};
                end
            end
            $fclose(ifp);
            $fclose(ofp);
        end
end
endtask // convert_mif2ver

/****************************************************************/
/* Read in Intel-hex format data to verilog format data.        */
/*  Intel-hex format    :nnaaaaattddddcc                        */
/****************************************************************/
task convert_hex2ver;
    input[`MAX_NAME_SZ*8 : 1] in_file;
    input width;
    output [`MAX_NAME_SZ*8 : 1] out_file;
    reg [`MAX_NAME_SZ*8 : 1] in_file;
    reg [`MAX_NAME_SZ*8 : 1] out_file;
    reg [8:1] c;
    reg [3:0] hex, tmp_char;
    reg done;
    reg error_status;
    reg first_rec;
    reg last_rec;
    reg first_normal_record;
    reg is_word_address_format;

    integer width;
    integer ifp, ofp, r, r2;
    integer i, j, k, m, n;

    integer off_addr, nn, aaaa, aaaa_pre, tt, cc, aah, aal, dd, sum ;
    integer line_no;
    integer divide_factor;

begin
        done = `FALSE;
        error_status = `FALSE;
        first_rec = `FALSE;
        last_rec = `FALSE;
        first_normal_record = `TRUE;
        is_word_address_format = `FALSE;
        off_addr= 0;
        nn= 0;
        aaaa= 0;
        aaaa_pre = 0;
        tt= 0;
        cc= 0;
        aah= 0;
        aal= 0;
        dd= 0;
        sum = 0;
        line_no = 1;
        c = 0;
        hex = 0;
        divide_factor = 1;

        if((in_file[4*8 : 1] == ".dat") || (in_file[4*8 : 1] == ".DAT"))
            out_file = in_file;
        else
        begin
            ifp = $fopen(in_file, "r");
            if (ifp == `NULL)
            begin
                $display("ERROR: cannot read %0s.", in_file);
                done = `TRUE;
            end

            out_file = in_file;

            if((out_file[4*8 : 1] == ".hex") || (out_file[4*8 : 1] == ".HEX"))
                out_file[3*8 : 1] = `EXT_STR;
            else
            begin
                $display("ERROR: Invalid input file name %0s. Expecting file with .hex extension and Intel-hex data format.", in_file);
                done = `TRUE;
            end

            if (!done)
            begin
                ofp = $fopen(out_file, "w");
                if (ofp == `NULL)
                begin
                    $display("ERROR : cannot write %0s.", out_file);
                    done = `TRUE;
                end
            end

            while((!done) && (!error_status))
            begin : READER

                r = $fgetc(ifp);

                if (r == `EOF)
                begin
                    if(!first_rec)
                    begin
                        error_status = `TRUE;
                        $display("WARNING: %0s, Intel-hex data file is empty.", in_file);
                        $display ("Time: %0t  Instance: %m", $time);
                    end
                    else if(!last_rec)
                    begin
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Missing the last record.", in_file, line_no);
                    end
                end
                else if (r == `COLON)
                begin
                    first_rec = `TRUE;
                    nn= 0;
                    aaaa_pre = aaaa;
                    aaaa= 0;
                    tt= 0;
                    cc= 0;
                    aah= 0;
                    aal= 0;
                    dd= 0;
                    sum = 0;

                    // get record length bytes
                    for (i = 0; i < 2; i = i+1)
                    begin
                        r = $fgetc(ifp);

                        if ((r >= "0") && (r <= "9"))
                            nn = (nn * 16) + (r - 'h30);
                        else if ((r >= "A") && (r <= "F"))
                            nn = (nn * 16) + 10 + (r - 'h41);
                        else if ((r >= "a") && (r <= "f"))
                            nn = (nn * 16) + 10 + (r - 'h61);
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                            done = `TRUE;
                            disable READER;
                        end
                    end

                    // get address bytes
                    for (i = 0; i < 4; i = i+1)
                    begin
                        r = $fgetc(ifp);

                        if ((r >= "0") && (r <= "9"))
                            hex = (r - 'h30);
                        else if ((r >= "A") && (r <= "F"))
                            hex = 10 + (r - 'h41);
                        else if ((r >= "a") && (r <= "f"))
                            hex = 10 + (r - 'h61);
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                            done = `TRUE;
                            disable READER;
                        end

                        aaaa = (aaaa * 16) + hex;

                        if (i < 2)
                            aal = (aal * 16) + hex;
                        else
                            aah = (aah * 16) + hex;
                    end

                    // get record type bytes
                    for (i = 0; i < 2; i = i+1)
                    begin
                        r = $fgetc(ifp);

                        if ((r >= "0") && (r <= "9"))
                            tt = (tt * 16) + (r - 'h30);
                        else if ((r >= "A") && (r <= "F"))
                            tt = (tt * 16) + 10 + (r - 'h41);
                        else if ((r >= "a") && (r <= "f"))
                            tt = (tt * 16) + 10 + (r - 'h61);
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                            done = `TRUE;
                            disable READER;
                        end
                    end

                    if((tt == 2) && (nn != 2) )
                    begin
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Invalid data record.", in_file, line_no);
                    end
                    else
                    begin

                        // get the sum of all the bytes for record length, address and record types
                        sum = nn + aah + aal + tt ;

                        // check the record type
                        case(tt)
                            // normal_record
                            8'h00 :
                            begin
                                first_rec = `TRUE;
                                i = 0;
                                k = width / `AWORD;
                                if ((width % `AWORD) != 0)
                                    k = k + 1;

                                if ((first_normal_record == `FALSE) &&(aaaa != k))
                                    is_word_address_format = `TRUE;

                                first_normal_record = `FALSE;

                                if ((aaaa == k) && (is_word_address_format == `FALSE))
                                    divide_factor = k;

                                // k = no. of bytes per entry.
                                while (i < nn)
                                begin
                                    $fdisplay(ofp,"@%0h", (aaaa + off_addr)/divide_factor);

                                    for (j = 1; j <= k; j = j +1)
                                    begin
                                        if ((k - j +1) > nn)
                                        begin
                                            for(m = 1; m <= 2; m= m+1)
                                            begin
                                                if((((k-j)*8) + ((3-m)*4) - width) < 4)
                                                    $fwrite(ofp, "0");
                                            end
                                        end
                                        else
                                        begin
                                            // get the data bytes
                                            for(m = 1; m <= 2; m= m+1)
                                            begin
                                                r = $fgetc(ifp);

                                                if ((r >= "0") && (r <= "9"))
                                                    hex = (r - 'h30);
                                                else if ((r >= "A") && (r <= "F"))
                                                    hex = 10 + (r - 'h41);
                                                else if ((r >= "a") && (r <= "f"))
                                                    hex = 10 + (r - 'h61);
                                                else
                                                begin
                                                    error_status = `TRUE;
                                                    $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                                                    done = `TRUE;
                                                    disable READER;
                                                end

                                                if((((k-j)*8) + ((3-m)*4) - width) < 4)
                                                    $fwrite(ofp, "%h", hex);
                                                dd = (dd * 16) + hex;

                                                if(m % 2 == 0)
                                                begin
                                                    sum = sum + dd;
                                                    dd = 0;
                                                end
                                            end
                                        end
                                    end
                                    $fwrite(ofp, "\n");

                                    i = i + k;
                                    aaaa = aaaa + 1;
                                end // end of while (i < nn)
                            end
                            // last record
                            8'h01:
                            begin
                                last_rec = `TRUE;
                                done = `TRUE;
                            end
                            // address base record
                            8'h02:
                            begin
                                off_addr= 0;

                                // get the extended segment address record
                                for(i = 1; i <= (nn*2); i= i+1)
                                begin
                                    r = $fgetc(ifp);

                                    if ((r >= "0") && (r <= "9"))
                                        hex = (r - 'h30);
                                    else if ((r >= "A") && (r <= "F"))
                                        hex = 10 + (r - 'h41);
                                    else if ((r >= "a") && (r <= "f"))
                                        hex = 10 + (r - 'h61);
                                    else
                                    begin
                                        error_status = `TRUE;
                                        $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                                        done = `TRUE;
                                        disable READER;
                                    end

                                    off_addr = (off_addr * `H10) + hex;
                                    dd = (dd * 16) + hex;

                                    if(i % 2 == 0)
                                    begin
                                        sum = sum + dd;
                                        dd = 0;
                                    end
                                end

                                off_addr = off_addr * `H10;
                            end
                            // address base record
                            8'h03:
                                // get the start segment address record
                                for(i = 1; i <= (nn*2); i= i+1)
                                begin
                                    r = $fgetc(ifp);

                                    if ((r >= "0") && (r <= "9"))
                                        hex = (r - 'h30);
                                    else if ((r >= "A") && (r <= "F"))
                                        hex = 10 + (r - 'h41);
                                    else if ((r >= "a") && (r <= "f"))
                                        hex = 10 + (r - 'h61);
                                    else
                                    begin
                                        error_status = `TRUE;
                                        $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                                        done = `TRUE;
                                        disable READER;
                                    end
                                    dd = (dd * 16) + hex;

                                    if(i % 2 == 0)
                                    begin
                                        sum = sum + dd;
                                        dd = 0;
                                    end
                                end
                            // address base record
                            8'h04:
                            begin
                                off_addr= 0;

                                // get the extended linear address record
                                for(i = 1; i <= (nn*2); i= i+1)
                                begin
                                    r = $fgetc(ifp);

                                    if ((r >= "0") && (r <= "9"))
                                        hex = (r - 'h30);
                                    else if ((r >= "A") && (r <= "F"))
                                        hex = 10 + (r - 'h41);
                                    else if ((r >= "a") && (r <= "f"))
                                        hex = 10 + (r - 'h61);
                                    else
                                    begin
                                        error_status = `TRUE;
                                        $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                                        done = `TRUE;
                                        disable READER;
                                    end

                                    off_addr = (off_addr * `H10) + hex;
                                    dd = (dd * 16) + hex;

                                    if(i % 2 == 0)
                                    begin
                                        sum = sum + dd;
                                        dd = 0;
                                    end
                                end

                                off_addr = off_addr * `H10000;
                            end
                            // address base record
                            8'h05:
                                // get the start linear address record
                                for(i = 1; i <= (nn*2); i= i+1)
                                begin
                                    r = $fgetc(ifp);

                                    if ((r >= "0") && (r <= "9"))
                                        hex = (r - 'h30);
                                    else if ((r >= "A") && (r <= "F"))
                                        hex = 10 + (r - 'h41);
                                    else if ((r >= "a") && (r <= "f"))
                                        hex = 10 + (r - 'h61);
                                    else
                                    begin
                                        error_status = `TRUE;
                                        $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                                        done = `TRUE;
                                        disable READER;
                                    end
                                    dd = (dd * 16) + hex;

                                    if(i % 2 == 0)
                                    begin
                                        sum = sum + dd;
                                        dd = 0;
                                    end
                                end
                            default:
                            begin
                                error_status = `TRUE;
                                $display("ERROR: %0s, line %0d, Unknown record type.", in_file, line_no);
                            end
                        endcase

                        // get the checksum bytes
                        for (i = 0; i < 2; i = i+1)
                        begin
                            r = $fgetc(ifp);

                            if ((r >= "0") && (r <= "9"))
                                cc = (cc * 16) + (r - 'h30);
                            else if ((r >= "A") && (r <= "F"))
                                cc = 10 + (cc * 16) + (r - 'h41);
                            else if ((r >= "a") && (r <= "f"))
                                cc = 10 + (cc * 16) + (r - 'h61);
                            else
                            begin
                                error_status = `TRUE;
                                $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                                done = `TRUE;
                                disable READER;
                            end
                        end

                        // Perform check sum.
                        if(((~sum+1)& `MASK15) != cc)
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid checksum.", in_file, line_no);
                        end
                    end
                end
                else if ((r == `NEWLINE) || (r == `CARRIAGE_RETURN))
                begin
                    line_no = line_no +1;
                end
                else if (r == `SPACE)
                begin
                    // continue to next character;
                end
                else
                begin
                    error_status = `TRUE;
                    $display("ERROR:%0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                    done = `TRUE;
                end
            end
            $fclose(ifp);
            $fclose(ofp);
        end
end
endtask // convert_hex2ver

task convert_to_ver_file;
    input[`MAX_NAME_SZ*8 : 1] in_file;
    input width;
    output [`MAX_NAME_SZ*8 : 1] out_file;
    reg [`MAX_NAME_SZ*8 : 1] in_file;
    reg [`MAX_NAME_SZ*8 : 1] out_file;
    integer width;
begin

        if((in_file[4*8 : 1] == ".hex") || (in_file[4*8 : 1] == ".HEX") ||
            (in_file[4*8 : 1] == ".dat") || (in_file[4*8 : 1] == ".DAT"))
            convert_hex2ver(in_file, width, out_file);
        else if((in_file[4*8 : 1] == ".mif") || (in_file[4*8 : 1] == ".MIF"))
            convert_mif2ver(in_file, width, out_file);
        else
            $display("ERROR: Invalid input file name %0s. Expecting file with .hex extension (with Intel-hex data format) or .mif extension (with Altera-mif data format).", in_file);
end
endtask // convert_to_ver_file

endmodule // ALTERA_MF_MEMORY_INITIALIZATION

