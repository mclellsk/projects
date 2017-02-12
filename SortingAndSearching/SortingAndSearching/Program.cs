using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using SortLibrary;

namespace SortingAndSearching
{
    class Program
    {
        public const string cmdBubblesort= "/bubs";
        public const string cmdMergesort = "/mers";
        public const string cmdQuicksort = "/quis";
        public const string cmdSelectionsort = "/sels";
        public const string cmdRadixsort = "/rads";
        public const string cmdBucketsort = "/bucs";
        public const string cmdCountingSort = "/cous";

        public static Dictionary<string, string> cmdList = new Dictionary<string, string>()
        {
            { cmdBubblesort, cmdBubblesort + " [array] - Performs a bubble sort" },
            { cmdBucketsort, cmdBucketsort + " [array] - Performs a bucket sort" },
            { cmdMergesort, cmdMergesort + " [array] - Performs a merge sort" },
            { cmdQuicksort, cmdQuicksort + " [array] - Performs a quick sort" },
            { cmdRadixsort, cmdRadixsort + " [array] - Performs a radix sort" },
            { cmdSelectionsort, cmdSelectionsort + " [array] - Performs a selection sort" },
            { cmdCountingSort, cmdCountingSort + " [array] - Performs a counting sort" }
        };

        static void Main(string[] args)
        {
            while (true)
            {
                int[] array;
                var param = Console.ReadLine().Split(' ');
                switch (param[0])
                {
                    case "/help":
                        foreach (string key in cmdList.Keys)
                            Console.WriteLine("{0}", cmdList[key]);
                        break;
                    case cmdBubblesort:
                        array = ParseArray(param[1]);
                        if (array != null)
                            Sorter.BubbleSort(ref array);
                        Console.WriteLine(Sorter.ShowArray(array));
                        break;
                    case cmdBucketsort:
                        array = ParseArray(param[1]);
                        if (array != null)
                            Sorter.BucketSort(ref array);
                        Console.WriteLine(Sorter.ShowArray(array));
                        break;
                    case cmdCountingSort:
                        array = ParseArray(param[1]);
                        if (array != null)
                            Sorter.CountingSort(ref array);
                        Console.WriteLine(Sorter.ShowArray(array));
                        break;
                    case cmdMergesort:
                        array = ParseArray(param[1]);
                        if (array != null)
                            Sorter.MergeSort(ref array, 0, array.Length - 1);
                        Console.WriteLine(Sorter.ShowArray(array));
                        break;
                    case cmdQuicksort:
                        array = ParseArray(param[1]);
                        if (array != null)
                            Sorter.QuickSort(ref array, 0, array.Length - 1);
                        Console.WriteLine(Sorter.ShowArray(array));
                        break;
                    case cmdRadixsort:
                        array = ParseArray(param[1]);
                        if (array != null)
                            Sorter.RadixHelper(ref array);
                        Console.WriteLine(Sorter.ShowArray(array));
                        break;
                    case cmdSelectionsort:
                        array = ParseArray(param[1]);
                        if (array != null)
                            Sorter.SelectionSort(ref array);
                        Console.WriteLine(Sorter.ShowArray(array));
                        break;
                    default:
                        Console.WriteLine("Command unknown, try /help for commands.");
                        break;
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="input"></param>
        /// <returns></returns>
        public static int[] ParseArray(string input)
        {
            if (Regex.IsMatch(input, @"^[\[](([0-9]+\,)*[0-9]+)[\]]$"))
            {
                input = input.Trim('[', ']');
                var values = input.Split(',');
                var result = new int[values.Length];
                try
                {
                    for (int i = 0; i < values.Length; i++)
                        result[i] = Convert.ToInt32(values[i]);
                }
                catch (Exception e)
                {
                    Console.WriteLine(e.ToString());
                }
                return result;
            }
            else
            {
                Console.WriteLine("{0} not formatted correctly.", input);
            }
            return null;
        }
    }
}
