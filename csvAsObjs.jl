using ArgParse
function inferDelim(sampleLines)
	chars = unique(sampleLines[1]) #We don't care about all possible chars in the sample. The delimiter should be in the first line (and any line)
	
	return delim
end
function main(args)
		#initialize settings for argparse library
	s = ArgParseSettings(description = "Script to create live objects from rows in csv")
	@add_arg_table opts begin
		"--delimiter", "-d" 
			help = "Specifies the delimiter for the csv. If none is specified, one is inferred"
		"file", "--file" 
			help = "Argument for the csv file to read in. Can be either positional or indicated using a flag"
			required = true
	end
	parsed_args = parse_args(s)
	#Read first line of csv in so we can figure out what the headings should be
	if length(ARGS) > 1
		open(ARGS[1]) do csvInput 
			src = readlines(csvInput)
			header = src[1]
			if(haskey(parsed_args, "--delimiter"))
				delim = parsed_args["--delimiter"]
			elseif(haskey(parsed_args, "-d"))
				delim = parsed_args["-d"]
			else
				lenFile = length(src)
				if(lenFile > 10)
					sampleLines = src[1:5:end]
				else
					sampleLines = src[:]
				end
				delim = inferDelim(sampleLines)	
			end	
		end
	end
end
