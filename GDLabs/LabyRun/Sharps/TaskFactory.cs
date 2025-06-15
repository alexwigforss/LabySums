using Godot;
using System;

public class TaskFactory : Node2D
{
	static char? prevChar = null;
	static Expression expression;
	static void createExpression(int nrOfOperators)
	{
		expression = new Expression(nrOfOperators, true);
	}
	static int charToNum(char c){
		switch (c)
		{
			case '+':
				return 0;
			case '-':
				return 1;
			case '*':
				return 2;
			case '/':
				return 3;
			default:
				return -1;
		}

	}
	static int[] getNums()
	{
		int[] result = new int[(expression.getLength() + 1) / 2];
		if (expression == null)
		{
			throw new InvalidOperationException("Expression cannot be null!");
		}
		else
		{
			int j = 0;
			for (int i = 0; i < result.Length; i++)
			{
				// Console.Write("Index: " + i + " ");
				Ep ent = expression.epsArr[i + j++];
				// Console.WriteLine(ent + " " + ent.GetType());
				result[i] = int.Parse(ent.ToString());
			}
		}
		return result;
	}
	static int[] getSigns()
	{
		int[] result = new int[(expression.getLength() + 1) / 2 - 1];
		if (expression == null)
		{
			throw new InvalidOperationException("Expression cannot be null!");
		}
		else
		{
			int j = 0;
			for (int i = 1; i < result.Length + 1; i++)
			{
				Console.Write("Index: " + i + " ");
				Ep ent = expression.epsArr[i + j++];
				Console.WriteLine(ent + " " + ent.GetType());
				result[i - 1] = charToNum(ent.Sign);
			}
		}
		return result;
	}
	
	//private Expression logic = new Expression();
	Expression exp = new Expression(2, true);


	public override void _Ready()
	{
//		createExpression(2);
//		GD.Print(exp.SayHello());
//		int[] nums = getNums();
//		int[] signs = getSigns();
//		foreach (var item in nums)
//		{
//			GD.Print(item + " ");
//		}
//		GD.Print(nums);
//
//		foreach (var item in signs)
//		{
//			GD.Print(item + " ");
//		}
//		GD.Print("0"," ",signs);
	}
	
	public int[] AddNumbers(int a, int b)
	{
		int[] output = new int[2] { a,b } ;
		return output;
	}
}
