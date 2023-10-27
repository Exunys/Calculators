import java.util.Stack;
import java.util.EmptyStackException;

public class Main {
	static Stack<Double> values = new Stack<>();
	static Stack<Character> operators = new Stack<>();

	static int getOperatorPrecedence(char operation) {
		if (operation == '+' || operation == '-') {
			return 1;
		} else if (operation == '*' || operation == '/' || operation == '%') {
			return 2;
		} else if (operation == '^') {
			return 3;
		}
		return 0; // Default precedence
	}

	static boolean hasHigherPrecedence(char operation1, char operation2) {
		return getOperatorPrecedence(operation1) >= getOperatorPrecedence(operation2);
	}

	static boolean isOperator(char character) {
		return character == '+' || character == '-' || character == '*' || character == '/' || character == '%' || character == '^';
	}

	static double performOperation(double a, double b, char operation) {
		switch (operation) {
			case '+':
				return a + b;
			case '-':
				return a - b;
			case '*':
				return a * b;
			case '/':
				return a / b;
			case '%':
				return a % b;
			case '^':
				return Math.pow(a, b);
			default:
				return 0;
		}
	}

	static void manageStack() {
		char operation;
		try {
			operation = operators.pop();
		} catch (EmptyStackException e) {
			throw new IllegalStateException("Invalid expression!");
		}

		if (values.size() < 2) {
			throw new IllegalStateException("Invalid expression!");
		}

		double b = values.pop();
		double a = values.pop();

		values.push(performOperation(a, b, operation));
	}

	static double evaluateExpression(String expression) {
		for (int index = 0; index < expression.length(); index++) {
			char value = expression.charAt(index);

			if (Character.isWhitespace(value)) { // Skip spaces
				continue;
			} else if (Character.isDigit(value) || (value == '-' && (index == 0 || isOperator(expression.charAt(index - 1))))) {
				int _index = index;

				while (_index < expression.length() && (Character.isDigit(expression.charAt(_index)) || expression.charAt(_index) == '.')) {
					_index++;
				}

				values.push(Double.parseDouble(expression.substring(index, _index)));
				index = _index - 1;
			} else if (value == '(') {
				operators.push(value);
			} else if (value == ')') {
				while (!operators.isEmpty() && operators.peek() != '(') {
					manageStack();
				}

				try {
					operators.pop(); // Pop the opening parenthesis - "("
				} catch (EmptyStackException e) {
					throw new IllegalStateException("Invalid expression!");
				}
			} else if (isOperator(value)) {
				while (!operators.isEmpty() && operators.peek() != '(' && hasHigherPrecedence(operators.peek(), value)) {
					manageStack();
				}

				operators.push(value);
			} else {
				throw new IllegalStateException("Invalid character in expression!");
			}
		}

		while (!operators.isEmpty()) {
			manageStack();
		}

		if (values.size() != 1) {
			throw new IllegalStateException("Invalid expression!");
		}

		return values.peek();
	}

	public static void main(String[] args) {
		String expression;

		while (true) {
			System.out.print("\n Insert algorithm:\n\n  [>] ");
			expression = new java.util.Scanner(System.in).nextLine();

			try {
				System.out.println("\n Stack returns (result):\n\n  [>]  " + evaluateExpression(expression));
			} catch (Exception error) {
				System.out.println("\n Error: " + error.getMessage() + "\n");
			}
		}
	}
}
