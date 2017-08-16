using ArgParse
function inferDelim(sampleLines)
	typicalDelim = [',','\t','|',' ']
	delim = typicalDelim[end]
	modFlag = 0
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
			if candidate in typicalDelim && findfirst(typicalDelim, candidate) <= findfirst(typicalDelim, delim)
				delim = candidate
				modFlag = 1
			end
		end
	end
	if modFlag == 0
		print("Unable to successfully identify the correct delimiter.")
		showDelim(sampleLines, potentialDelims)
		print("Which delimiter looks most appropriate?")
		delim = readline(STDIN)
	end
	return delim 
end
function showDelim(sampleLines, potentialDelims)
	stringCandidates = arrayAsEngString(potentialDelims)
	print("The potential delimiter candidates are $stringCandidates")
	for delim in potentialDelims
		print("The split for $delim in this file is")
		splitHeader = truncSepSamples(sampleLines[1], delim)
		splitLine1 = truncSepSamples(sampleLines[2], delim)
		splitLine2 = truncSepSamples(sampleLines[3], delim) 
	end
end
function truncSepSamples(sampleLine, delim)
	splitLine = split(sampleLine, ",")
	truncLine = ""
	for piece in splitLine
		pieceLength = length(piece)
		if pieceLength > 5
			truncLine *= piece[1:5] * "..." 
		else
			truncLine *= piece * (" " ^ (7-pieceLength))
		end
	end
	return truncLine
end
function arrayAsEngString(inputArray::Array)
	str = ""
	for i in eachindex(inputArray)
		if i != size(inputArray)[1]
			str *= " $(inputArray[i]),"
		else
			str *= " and $(inputArray[i])"
		end
	end
	return str
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
				print(delim)	
			end	
		end
	end
end
main(ARGS)
