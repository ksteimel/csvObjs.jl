using ArgParse
function main(args)
	#initialize settings for argparse library
	s = ArgParseSettings(description = "Script to create live objects from rows in csv")
	@add_arg_table opts begin
		"--delimiter", "-d" #specifies the delimiter for the csv. If none is specified, one is inferred
		"file", "--file" #argument for the csv file to read in. Can be either positional or indicated using a flag

	end
	#Read first line of csv in so we can figure out what the headings should be
	if length(ARGS) > 1
		open(ARGS[1]) do csvInput 
			s = readstring(csvInput)
			header = s[1]
			
		end
	end
end
