using System.Globalization;
using System.Security.Cryptography.X509Certificates;
using System.Xml.XPath;

namespace TaskMaker;
// ['+','-','*','/']
class Program
{
    static char? prevChar = null;
    static Expression expression;
    static void createExpression(int nrOfOperators)
    {
        expression = new(nrOfOperators, true);
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
    static void Main(string[] args)
    {
        Console.WriteLine("Hello, World!");
        while (true)
        {
            Expression exp = new(2, true);
        createExpression(2);
        int[] nums = getNums();
        int[] signs = getSigns();

        foreach (var item in nums)
        {
            Console.Write(item + " ");
        }
        Console.WriteLine(nums);

        foreach (var item in signs)
        {
            Console.Write(item + " ");
        }
        Console.WriteLine(signs);

            foreach (object q in expression.Eps)
            {
                Console.Write(q.ToString() + " ");
            }
            Console.Write($" = {expression.Calculate()} ");
            Console.WriteLine();
            Console.WriteLine(expression.epsArr.Length );
            if (Console.ReadKey().Key == ConsoleKey.Q)
               break;
            prevChar = null;
        }

    }
}
