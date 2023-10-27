using System;
using System.Collections.Generic;

class Program {
	static bool IsOperator(char Char) {
		return Char == '+' || Char == '-' || Char == '*' || Char == '/' || Char == '%' || Char == '^';
	}

	static double PerformOperation(double A, double B, char Operation) {
		switch (Operation) {
			case '+':
				return A + B; // ADD
			case '-':
				return A - B; // SUB
			case '*':
				return A * B; // MUL
			case '/':
				return A / B; // DIV
			case '%':
				return A % B; // MOD
			case '^':
				return Math.Pow(A, B); // POW
			default:
				return 0;
		}
	}

	static double EvaluateExpression(string Expression) {
		Stack<double> Values = new Stack<double>();
		Stack<char> Operators = new Stack<char>();

		for (int Index = 0; Index < Expression.Length; Index++) {
			if (char.IsWhiteSpace(Expression[Index])) {
				continue;
			} else if (char.IsDigit(Expression[Index]) || (Expression[Index] == '-' && (Index == 0 || IsOperator(Expression[Index - 1])))) {
				int _Index = Index;

				while (_Index < Expression.Length && (char.IsDigit(Expression[_Index]) || Expression[_Index] == '.')) {
					_Index++;
				}

				double Number = double.Parse(Expression.Substring(Index, _Index - Index));
				Values.Push(Number); // Insert number constant into stack

				Index = _Index - 1;
			} else if (Expression[Index] == '(') {
				Operators.Push(Expression[Index]);
			} else if (Expression[Index] == ')') {
				while (Operators.Count > 0 && Operators.Peek() != '(') {
					char Operation = Operators.Pop();

					if (Values.Count < 2) {
						throw new InvalidOperationException("Invalid Expression");
					}

					double B = Values.Pop();
					double A = Values.Pop();
					double Result = PerformOperation(A, B, Operation);

					Values.Push(Result);
				}

				Operators.Pop(); // Pop the opening parenthesis - "("
			} else if (IsOperator(Expression[Index])) {
				while (Operators.Count > 0 && Operators.Peek() != '(' && IsOperator(Operators.Peek()) && (Expression[Index] == '^' ? Expression[Index] < Operators.Peek() : Expression[Index] <= Operators.Peek())) {
					char Operation = Operators.Pop();

					if (Values.Count < 2) {
						throw new InvalidOperationException("Invalid expression!");
					}

					double B = Values.Pop();
					double A = Values.Pop();
					double Result = PerformOperation(A, B, Operation);

					Values.Push(Result);
				}

				Operators.Push(Expression[Index]);
			} else {
				throw new InvalidOperationException("Invalid character in expression!");
			}
		}

		while (Operators.Count > 0) {
			char Operation = Operators.Pop();

			if (Values.Count < 2) {
				throw new InvalidOperationException("Invalid expression!");
			}

			double B = Values.Pop();
			double A = Values.Pop();
			double Result = PerformOperation(A, B, Operation);

			Values.Push(Result);
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
