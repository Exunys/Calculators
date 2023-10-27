os.execute("title VM Based Arithmetic Model - By Exunys && color 08 && cls")

local Opcodes = {
	"LOADK",
	"ADD",
	"SUB",
	"MUL",
	"DIV",
	"MOD",
	"EXP"
}

local Lexer = function(Input)
	local Tokens, Index = {}, 1

	while Index <= #Input do
		local Character = string.sub(Input, Index, Index)

		if string.match(Character, "%s") then -- Whitespace
			Index = Index + 1
		elseif string.match(Character, "%d") then -- Integer
			local Number = ""

			while string.match(Character, "%d") do
				Number = Number..Character
				Index = Index + 1
				Character = string.sub(Input, Index, Index)
			end

			Tokens[#Tokens + 1] = {
				Type = "NUMBER",
				Value = tonumber(Number)
			}
		elseif Character == "+" or Character == "-" or Character == "*" or Character == "/" or Character == "%" or Character == "^" then -- Operator
			Tokens[#Tokens + 1], Index = {
				Type = "OPERATOR",
				Value = Character
			}, Index + 1
		elseif Character == "(" or Character == ")" then -- Parenthesis
			Tokens[#Tokens + 1], Index = {
				Type = "PARENTHESIS",
				Value = Character
			}, Index + 1
		else
			error("Unknown character: "..Character)
		end
	end

	return Tokens
end

local Parse = function(Tokens)
	local Precedence, Index = {
		["+"] = 1,
		["-"] = 1,
		["*"] = 2,
		["/"] = 2,
		["%"] = 2,
		["^"] = 3
	}, 1

	local function ParseExpression()
		local _Parse = function()
			local Token = Tokens[Index]

			if Token.Type == "NUMBER" then
				Index = Index + 1

				return {
					Type = "NUMBER",
					Value = Token.Value
				}
			elseif Token.Type == "PARENTHESIS" and Token.Value == "(" then
				Index = Index + 1

				local Expression, ClosingParenthesis = ParseExpression(), Tokens[Index]

				if ClosingParenthesis.Type ~= "PARENTHESIS" or ClosingParenthesis.Value ~= ")" then
					error("Expected closing parenthesis, got "..ClosingParenthesis.Type)
				end

				Index = Index + 1

				return Expression
			else
				error("Expected expression, got "..Token.Type)
			end
		end

		local function ParseBinaryOp(MinimumPrecedence)
			local Left = _Parse()

			while Index <= #Tokens do
				local Token = Tokens[Index]

				if Token.Type ~= "OPERATOR" or not Precedence[Token.Value] then
					break
				end

				local OpPrecedence = Precedence[Token.Value]

				if OpPrecedence < MinimumPrecedence then
					break
				end

				Index = Index + 1

				local Right = ParseBinaryOp(OpPrecedence + 1)

				Left = {
					Type = "BINARY_OP",
					Operation = Token.Value,
					Left = Left,
					Right = Right
				}
			end

			return Left
		end

		local Left = ParseBinaryOp(0)

		while Index <= #Tokens do
			local Token = Tokens[Index]
			if Token.Type == "PARENTHESIS" and Token.Value == "(" then
				local Right = ParseBinaryOp(0)

				Left = {
					Type = "BINARY_OP",
					Operation = "*",
					Left = Left,
					Right = Right
				}
			else
				break
			end
		end

		return Left
	end

	local _Parse = function()
		local Expressions = {}

		while Index <= #Tokens do
			Expressions[#Expressions + 1] = ParseExpression()
		end

		return {
			Type = "PROGRAM",
			Expressions = Expressions
		}
	end

	return _Parse()
end

local Compile = function(AST)
	local Bytecode, Constants = {}, {}

	local function Visit(Node)
		if Node.Type == "NUMBER" then
			local Index = #Constants + 1

			Constants[#Constants + 1] = Node.Value
			Bytecode[#Bytecode + 1] = 1 -- LOADK (Load Constant) opcode
			Bytecode[#Bytecode + 1] = Index
		elseif Node.Type == "BINARY_OP" then
			Visit(Node.Left); Visit(Node.Right)

			if Node.Operation == "+" then
				Bytecode[#Bytecode + 1] = 2 -- ADD (Add) opcode
			elseif Node.Operation == "-" then
				Bytecode[#Bytecode + 1] = 3 -- SUB (Subtraction) opcode
			elseif Node.Operation == "*" then
				Bytecode[#Bytecode + 1] = 4 -- MUL (Multiplication) opcode
			elseif Node.Operation == "/" then
				Bytecode[#Bytecode + 1] = 5 -- DIV (Division) opcode
			elseif Node.Operation == "%" then
				Bytecode[#Bytecode + 1] = 6 -- MOD (Modulo) opcode
			elseif Node.Operation == "^" then
				Bytecode[#Bytecode + 1] = 7 -- EXP (Exponentiation) opcode
			else
				error("Unknown operator: "..Node.Operation)
			end
		else
			error("Unknown node type: "..Node.Type)
		end
	end

	for _, Expression in next, AST.Expressions do
		Visit(Expression)
	end

	return Bytecode, Constants
end

local VM_Execute = function(Bytecode, Constants)
	local Stack, Pointer, Index = {}, 0, 1

	local Push, Pop = function(Value)
		Pointer = Pointer + 1
		Stack[Pointer] = Value
	end, function()
		local Value = Stack[Pointer]
		Pointer = Pointer - 1
		return Value
	end

	while Index <= #Bytecode do
		local Opcode = Bytecode[Index]

		if Opcode == 1 then -- LOADK
			Push(Constants[Bytecode[Index + 1]]); Index = Index + 2
		elseif Opcode == 2 then -- ADD
			Push(Pop() + Pop()); Index = Index + 1
		elseif Opcode == 3 then -- SUB
			local A, B = Pop(), Pop()
			Push(B - A); Index = Index + 1
		elseif Opcode == 4 then -- MUL
			Push(Pop() * Pop()); Index = Index + 1
		elseif Opcode == 5 then -- DIV
			local A, B = Pop(), Pop()
			Push(B / A); Index = Index + 1
		elseif Opcode == 6 then -- MOD
			local A, B = Pop(), Pop()
			Push(B % A); Index = Index + 1
		elseif Opcode == 7 then -- EXP
			local A, B = Pop(), Pop()
			Push(B ^ A); Index = Index + 1
 		else
			error("Unknown opcode: "..Opcode)
		end
	end

	-- Clear stack

	local Result = Pop()
	Pointer = 0

	return Result
end

local Run = function(Algorithm)
	local Tokens = Lexer(Algorithm)

	print("\n Tokens:\n")

	for Index, Token in next, Tokens do
		print(string.format("  [%s] > \"%s\" (%s)", Index, Token.Value, Token.Type))
	end

	local AST = Parse(Tokens)

	print("\n Abstract Syntax Tree (AST):\n")

	for _, Expression in next, AST.Expressions do
		print(string.format("  [%s] > \"%s\"", Expression.Type, Expression.Operation))
	end

	local Bytecode, Constants = Compile(AST)

	print("\n Bytecode:\n")

	for Index, Byte in next, Bytecode do
		print(string.format("  [%s] > %s > \"%s\"", Index, Byte, Opcodes[Byte]))
	end

	print("\n Constants:\n")

	for Index, Constant in next, Constants do
		print(string.format("  [%s] > \"%s\"", Index, Constant))
	end

	print("\n Stack returns (result):\n\n  [>] ", VM_Execute(Bytecode, Constants))
end

while true do
	io.write("\n Insert algorithm:\n\n  [>] ")

	local Input = io.read()

	if Input == "" then
		print("No input given!")
	elseif string.lower(Input) == "cls" then
		os.execute("cls")
	else
		Run(Input)
	end
end
