#include <iostream>
#include <string>
#include <stack>
#include <cmath>

using std::string;
using std::stack;
using std::runtime_error;
using std::cout;
using std::cin;
using std::getline;
using std::exception;

bool IsOperator(char Char) {
	return Char == '+' || Char == '-' || Char == '*' || Char == '/' || Char == '%' || Char == '^';
}

double PerformOperation(double A, double B, char Operation) {
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
			return fmod(A, B); // MOD
		case '^':
			return pow(A, B); // POW
		default:
			return 0;
	}
}

double EvaluateExpression(const string& Expression) {
	stack<double> Values;
	stack<char> Operators;

	for (size_t Index = 0; Index < Expression.size(); Index++) {
		if (isspace(Expression[Index])) {
			continue;
		} else if (isdigit(Expression[Index]) || (Expression[Index] == '-' && (Index == 0 || IsOperator(Expression[Index - 1])))) {
			size_t _Index = Index;
			
			while (_Index < Expression.size() && (isdigit(Expression[_Index]) || Expression[_Index] == '.')) {
				_Index++;
			}

			double Number = stod(Expression.substr(Index, _Index - Index));
			Values.push(Number); // Insert number constant into stack

			Index = _Index - 1;
		} else if (Expression[Index] == '(') {
			Operators.push(Expression[Index]);
		} else if (Expression[Index] == ')') {
			while (!Operators.empty() && Operators.top() != '(') {
				char Operation = Operators.top();
				Operators.pop();

				if (Values.size() < 2) {
					throw runtime_error("Invalid Expression");
				}

				double B = Values.top();
				Values.pop();
				double A = Values.top();
				Values.pop();
				double Result = PerformOperation(A, B, Operation);
				Values.push(Result);
			}

			Operators.pop(); // Pop the opening parenthesis - "("
		} else if (IsOperator(Expression[Index])) {
			while (!Operators.empty() && Operators.top() != '(' && IsOperator(Operators.top()) && (Expression[Index] == '^' ? Expression[Index] < Operators.top() : Expression[Index] <= Operators.top())) {
				char Operation = Operators.top();
				Operators.pop();

				if (Values.size() < 2) {
					throw runtime_error("Invalid expression!");
				}

				double B = Values.top();
				Values.pop();
				double A = Values.top();
				Values.pop();
				double Result = PerformOperation(A, B, Operation);
				Values.push(Result);
			}

			Operators.push(Expression[Index]);
		} else {
			throw runtime_error("Invalid character in expression!");
		}
	}

	while (!Operators.empty()) {
		char Operation = Operators.top();
		Operators.pop();

		if (Values.size() < 2) {
			throw runtime_error("Invalid expression!");
		}

		double B = Values.top();
		Values.pop();
		double A = Values.top();
		Values.pop();
		double Result = PerformOperation(A, B, Operation);
		Values.push(Result);
	}

	if (Values.size() != 1) {
		throw runtime_error("Invalid expression!");
	}

	return Values.top();
}

int main() {
	string Expression;

	std::system("title VM-based arithmetic model by Exunys && color 08");

	while (true) {
		cout << "\n Insert algorithm:\n\n  [>] ";
		getline(cin, Expression);

		try {
			cout << "\n Stack returns (result):\n\n  [>]  " << EvaluateExpression(Expression);
		} catch (const exception& Error) {
			cout << "\n Error: " << Error.what() << "\n";
		}
	}

	return 0;
}
