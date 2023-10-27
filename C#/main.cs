using System;
using System.Collections.Generic;

class Program {
	static Stack<double> Values = new Stack<double>();
	static Stack<char> Operators = new Stack<char>();

	static int GetOperatorPrecedence(char Operation) {
		if (Operation == '+' || Operation == '-') {
			return 1;
		} else if (Operation == '*' || Operation == '/' || Operation == '%') {
			return 2;
		} else if (Operation == '^') {
			return 3;
		}

		return 0; // Default precedence
	}

	static bool HasHigherPrecedence(char Operation1, char Operation2) {
		return GetOperatorPrecedence(Operation1) >= GetOperatorPrecedence(Operation2);
	}

	static bool IsOperator(char Char) {
		return Char == '+' || Char == '-' || Char == '*' || Char == '/' || Char == '%' || Char == '^';
	}

	static double PerformOperation(double A, double B, char Operation) {
		switch (Operation) {
			case '+':
				return A + B;
			case '-':
				return A - B;
			case '*':
				return A * B;
			case '/':
				return A / B;
			case '%':
				return A % B;
			case '^':
				return Math.Pow(A, B);
			default:
				return 0;
		}
	}

	static void ManageStack() {
		char Operation = Operators.Pop();

		if (Values.Count < 2) {
			throw new InvalidOperationException("Invalid expression!");
		}

		double B = Values.Pop();
		double A = Values.Pop();

		Values.Push(PerformOperation(A, B, Operation));
	}

	static double EvaluateExpression(string Expression) {
		for (int Index = 0; Index < Expression.Length; Index++) {
			char Value = Expression[Index];

			if (char.IsWhiteSpace(Value)) { // Skip spaces
				continue;
			} else if (char.IsDigit(Value) || (Value == '-' && (Index == 0 || IsOperator(Expression[Index - 1])))) {
				int _Index = Index;

				while (_Index < Expression.Length && (char.IsDigit(Expression[_Index]) || Expression[_Index] == '.')) {
					_Index++;
				}

				Values.Push(double.Parse(Expression.Substring(Index, _Index - Index)));
				Index = _Index - 1;
			} else if (Value == '(') {
				Operators.Push(Value);
			} else if (Value == ')') {
				while (Operators.Count > 0 && Operators.Peek() != '(') {
					ManageStack();
				}

				Operators.Pop(); // Pop the opening parenthesis - "("
			} else if (IsOperator(Value)) {
				while (Operators.Count > 0 && Operators.Peek() != '(' && HasHigherPrecedence(Operators.Peek(), Value)) {
					ManageStack();
				}

				Operators.Push(Value);
			} else {
				throw new InvalidOperationException("Invalid character in expression!");
			}
		}

		while (Operators.Count > 0) {
			ManageStack();
		}

		if (Values.Count != 1) {
			throw new InvalidOperationException("Invalid expression!");
		}

		return Values.Peek();
	}

	static void Main() {
		string Expression;

		Console.Title = "VM-based arithmetic model by Exunys";
		Console.BackgroundColor = ConsoleColor.Black;
		Console.ForegroundColor = ConsoleColor.Gray;

		while (true) {
			Console.Write("\n Insert algorithm:\n\n  [>] ");
			Expression = Console.ReadLine();

			try {
				Console.WriteLine("\n Stack returns (result):\n\n  [>]  " + EvaluateExpression(Expression));
			} catch (Exception Error) {
				Console.WriteLine("\n Error: " + Error.Message + "\n");
			}
		}
	}
}
