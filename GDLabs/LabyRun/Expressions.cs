using Godot;
using System;
using System.Collections.Generic; // Needed for Queue<T>

public class Expression
{
	Queue<Ep> eps;
	internal readonly Ep[] epsArr;
	//internal readonly int[] epsIntArr;
	static char? prevChar = null;
	internal Queue<Ep> Eps { get => eps; set => eps = value; }
	public int getLength()
	{
		return eps.Count;
	}

	public Expression(int amountOfOps, bool positive)
	{
		eps = GenerateExpression(amountOfOps, positive);
		epsArr = Eps.ToArray();
	}

	public Expression(int amountOfOps, bool positive, bool additives)
	{
		if (additives)
		{
			GD.Print("GENERATING ADDITIVE QUESTION");
			eps = GenerateExpression(amountOfOps, positive, true);
		}
		epsArr = Eps.ToArray();
	}

	private static Queue<Ep> GenerateExpression(int lvl, bool forcePositive = true, bool forceAddSub = false)
	{
		int sumSoFar = 0;
		Queue<Ep> expression = new Queue<Ep>();
		do
		{
			expression.Clear();
			int i = lvl * 2;
			while (i >= 0)
			{
				if (i % 2 != 0) // even
				{
					if (forceAddSub)
					{
						expression.Enqueue(new Op(ref sumSoFar, ref prevChar, true));
					}
					else
					{
						expression.Enqueue(new Op(ref sumSoFar, ref prevChar));						
					}
				}
				else if (i % 2 == 0) // odd
				{
					if (prevChar == '/')
					{
						expression.Enqueue(new Term(sumSoFar));
					}
					else
					{
						expression.Enqueue(new Term());
					}
					sumSoFar = Calculate(expression.ToArray());
				}
				i--;
			}
			if (!forcePositive)
			{
				return expression;
			}
		} while (Calculate(expression.ToArray()) < 0);
		return expression;
	}

	public float? CalculateConsume()
	{
		int sum;
		sum = eps.Dequeue().Num;
		while (eps.Count > 0)
		{
			char op = eps.Dequeue().Sign;
			int termB = eps.Dequeue().Num;
			sum = OperatorSwitch(sum, op, termB);
		}
		return sum;
	}
	
	public string SayHello() => "Hello from Expression!";

	public int Calculate()
	{
		int i = 0;
		int sum = epsArr[i++].Num;
		while (i < epsArr.Length - 1)
		{
			char op = epsArr[i++].Sign;
			int termB = epsArr[i++].Num;
			sum = OperatorSwitch(sum, op, termB);
		}
		return sum;
	}

	static int Calculate(Ep[] exp)
	{
		int i = 0;
		int sum = exp[i++].Num;
		while (i < exp.Length - 1)
		{
			char op = exp[i++].Sign;
			int termB = exp[i++].Num;
			sum = OperatorSwitch(sum, op, termB);
		}
		return sum;
	}

	private static int OperatorSwitch(int sum, char op, int termB)
	{
		switch (op)
		{
			case '+':
				sum += termB;
				break;
			case '-':
				sum -= termB;
				break;
			case '*':
				sum *= termB;
				break;
			case '/':
				sum /= termB;
				break;
			default:
				break;
		}
		return sum;
	}
}

internal class Ep
{
	public static Random rand = new Random();
	virtual public int Num { get; set; }
	virtual public char Sign { get; set; }
	public static bool IsPrime(int n)
	{
		for (int i = 2; i < n - 1; i++)
		{
			if (n % i == 0)
				return false;
		}
		return true;
	}
}

internal class Term : Ep
{
	public override int Num { get; set; }

	public Term()
	{
		Num = RandomInt();
	}

	public Term(int sumSoFar)
	{
		int[] v = ValidDividers(sumSoFar);
		if (v.Length < 2)
		{
			Num = 1;
		}
		else
		{
			Num = RandomInt(RandomInt(v));
		}
	}

	private static int RandomInt(int from = 1, int to = 9)
	{
		try
		{
			int n = rand.Next(from, to + 1);
			return n;
		}
		catch (Exception e)
		{
			Console.WriteLine(e.Message);
			return 1;
		}
	}

	private static int RandomInt(int[] amoung)
	{
		try
		{
			int n = amoung[rand.Next(0, amoung.Length - 1)];
			return n;
		}
		catch (Exception e)
		{
			Console.WriteLine(e.Message);
			return 1;
		}
	}

	private static int[] ValidDividers(float? n, bool write = false)
	{
		if (write)
			Console.Write("Ssf: " + n + " ");
		var list = new List<int>();
		for (int i = 1; i <= n; i++)
		{
			if (n % i == 0)
			{
				list.Add(i);
				if (write)
				{
					Console.Write(i + " ");
				}
			}
		}
		if (write)
			Console.WriteLine();
		return list.ToArray();
	}
	public override string ToString()
	{
		return Num.ToString();
	}
}

internal class Op : Ep
{
	static char[] signs = new char[] { '+', '-', '*', '/' };
	public override char Sign { get; set; }
	public Op(ref int sumSoFar, ref char? prevChar)
	{
		Sign = RandomSign(ref sumSoFar, out prevChar);
	}
	public Op(ref int sumSoFar, ref char? prevChar, bool additive = true)
	{
		Sign = RandomAddSub(ref sumSoFar, out prevChar);
	}
	private static char RandomSign(ref int sumSoFar, out char? pC)
	{
		char s;
		if (sumSoFar > 2 && !IsPrime(sumSoFar))
			s = signs[rand.Next(4)];
		else
			s = signs[rand.Next(3)];
		pC = s;
		return s;
	}

	private static char RandomAddSub(ref int sumSoFar, out char? pC)
	{
		char s;
		s = signs[rand.Next(2)];
		pC = s;
		return s;
	}


	public override string ToString()
	{
		return Sign.ToString();
	}
}
