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

stack<double> Values;
stack<char> Operators;

int GetOperatorPrecedence(char Operation) {
	if (Operation == '+' || Operation == '-') {
		return 1;
	} else if (Operation == '*' || Operation == '/' || Operation == '%') {
		return 2;
	} else if (Operation == '^') {
		return 3;
	}

	return 0; // Default precedence
}

bool HasHigherPrecedence(char Operation1, char Operation2) {
	return (int)(GetOperatorPrecedence(Operation1)) >= (int)(GetOperatorPrecedence(Operation2));
}

bool IsOperator(char Char) {
	return Char == '+' || Char == '-' || Char == '*' || Char == '/' || Char == '%' || Char == '^';
}

double PerformOperation(double A, double B, char Operation) {
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
			return fmod(A, B);
		case '^':
			return pow(A, B);
		default:
			return 0;
	}
}

void ManageStack() {
	char Operation = Operators.top();
	Operators.pop();

	if (Values.size() < 2) {
		throw runtime_error("Invalid expression!");
	}

	double B = Values.top();
	Values.pop();
	double A = Values.top();
	Values.pop();

	Values.push(PerformOperation(A, B, Operation));
}

double EvaluateExpression(const string& Expression) {
	for (size_t Index = 0; Index < Expression.size(); Index++) {
		const char Value = Expression[Index];

		if (isspace(Value)) { // Skip spaces
			continue;
		} else if (isdigit(Value) || (Value == '-' && (Index == 0 || IsOperator(Expression[Index - 1])))) {
			size_t _Index = Index;

			while (_Index < Expression.size() && (isdigit(Expression[_Index]) || Expression[_Index] == '.')) {
				_Index++;
			}

			Values.push(stod(Expression.substr(Index, _Index - Index)));
			Index = _Index - 1;
		} else if (Value == '(') {
			Operators.push(Value);
		} else if (Value == ')') {
			while (!Operators.empty() && Operators.top() != '(') {
				ManageStack();
			}

			Operators.pop(); // Pop the opening parenthesis - "("
		} else if (IsOperator(Value)) {
			while (!Operators.empty() && Operators.top() != '(' && HasHigherPrecedence(Operators.top(), Value)) {
				ManageStack();
			}

			Operators.push(Value);
		} else {
			throw runtime_error("Invalid character in expression!");
		}
	}

	while (!Operators.empty()) {
		ManageStack();
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
			cout << "\n Stack returns (result):\n\n  [>]  " << EvaluateExpression(Expression) << "\n";
		} catch (const exception& Error) {
			cout << "\n Error: " << Error.what() << "\n";
		}
	}

	return 0;
}
