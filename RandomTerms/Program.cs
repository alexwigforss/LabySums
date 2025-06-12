using System.Linq.Expressions;

namespace RandomTerms
{
    internal class Program
    {
        static Random rand = new Random();
        static char[] signs = ['+', '-', '*', '/'];
        static char? prevChar = null;
        static int sumSoFar = 0;

        static void Main(string[] args)
        {
            while (true)
            {
                Expression exp = new(2, true);
                foreach (object q in exp.Eps)
                {
                    Console.Write(q.ToString() + " ");
                }
                Console.Write($" = {exp.Calculate()} ");
                Console.WriteLine();
                if (Console.ReadKey().Key == ConsoleKey.Q)
                    break;
                prevChar = null;
            }
        }
    }
}
