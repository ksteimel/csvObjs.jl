using ArgParse
function inferDelim(sampleLines)
	typicalDelim = [',','\t','|',' ']
	delim = typicalDelim[end] 
	chars = unique(sampleLines[1]) #We don't care about all possible chars in the sample. The delimiter should be in the first line (and any line)
	tempCounts = zeros(Int8, length(chars), 1)
	countDict = Dict(zip(chars,tempCounts))
	for line in sampleLines
		countChars!(line, countDict)
	end
	potentialDelims = Char[]
	for char in keys(countDict)
 		if countDict[char] % length(sampleLines) == 0
			push!(potentialDelims, char)
		end
	end	
	if length(potentialDelims) > 1
		for candidate in potentialDelims
			if candidate in typicalDelim
				if findin(typicalDelim, candidate)[1] < findin(typicalDelim, candidate)[1]
					delim = candidate
				else
					continue
				end
			end
		end
	end
	return potentialDelims 
end
function countChars!(line::String, charCountDict::Dict)
	for char in line
		try charCountDict[char] += 1
		catch
			continue
		end	
	end
end
function main(args)
		#initialize settings for argparse library
	opts = ArgParseSettings(description = "Script to create live objects from rows in csv")
	@add_arg_table opts begin
		"--delimiter", "-d" 
			help = "Specifies the delimiter for the csv. If none is specified, one is inferred"
		"file" 
			help = "Argument for the csv file to read in. Can be either positional or indicated using a flag"
			required = true
	end

	parsed_args = parse_args(opts)
	#Read first line of csv in so we can figure out what the headings should be
	if length(parsed_args) > 1
		open(parsed_args["file"]) do csvInput 
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
main(ARGS)
