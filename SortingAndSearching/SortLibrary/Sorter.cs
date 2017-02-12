using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SortLibrary
{
    /// <summary>
    /// 
    /// </summary>
    public class Sorter
    {
        /// <summary>
        /// 
        /// </summary>
        /// <param name="array"></param>
        /// <returns></returns>
        public static string ShowArray(int[] array)
        {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < array.Length; i++)
            {
                sb.Append(array[i]);
                if (i != array.Length - 1)
                    sb.Append(",");
            }
            return sb.ToString();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="array"></param>
        /// <param name="minIndex"></param>
        /// <param name="maxIndex"></param>
        public static void QuickSort(ref int[] array, int minIndex, int maxIndex)
        {
            if (minIndex < 0 || maxIndex < 0)
                return;

            int partition = GetPartition(ref array, minIndex, maxIndex);
            //Quicksort the left half
            if (minIndex < partition - 1)
                QuickSort(ref array, minIndex, partition - 1);
            //Quicksort the right half   
            if (maxIndex > partition)
                QuickSort(ref array, partition, maxIndex);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="array"></param>
        /// <param name="minIndex"></param>
        /// <param name="maxIndex"></param>
        /// <returns></returns>
        private static int GetPartition(ref int[] array, int minIndex, int maxIndex)
        {
            var partition = minIndex + (maxIndex - minIndex) / 2;
            var pValue = array[partition];
            var left = minIndex;
            var right = maxIndex;
            while (left <= right)
            {
                //Get value on the left that needs to be on the right of the partition
                while (array[left] < pValue) left++;
                //Get value on the right that needs to be on the left of the partition
                while (array[right] > pValue) right--;

                if (left <= right)
                {
                    Swap(ref array, left, right);
                    left++;
                    right--;
                }
            }
            return left;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="array"></param>
        /// <param name="i"></param>
        /// <param name="j"></param>
        private static void Swap(ref int[] array, int i, int j)
        {
            var temp = array[i];
            array[i] = array[j];
            array[j] = temp;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="array"></param>
        /// <param name="minIndex"></param>
        /// <param name="maxIndex"></param>
        public static void MergeSort(ref int[] array, int minIndex, int maxIndex)
        {
            if (minIndex < maxIndex)
            {
                var midIndex = minIndex + (maxIndex - minIndex) / 2;
                MergeSort(ref array, minIndex, midIndex);
                MergeSort(ref array, midIndex + 1, maxIndex);
                Merge(ref array, minIndex, midIndex, maxIndex);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="array"></param>
        /// <param name="minIndex"></param>
        /// <param name="middleIndex"></param>
        /// <param name="maxIndex"></param>
        private static void Merge(ref int[] array, int minIndex, int middleIndex, int maxIndex)
        {
            var copy = new int[array.Length];
            for (int i = minIndex; i < copy.Length; i++)
                copy[i] = array[i];

            var leftIndex = minIndex;
            var rightIndex = middleIndex + 1;
            var newIndex = minIndex;

            while (leftIndex <= middleIndex && rightIndex <= maxIndex)
            {
                if (copy[leftIndex] <= copy[rightIndex])
                {
                    array[newIndex] = copy[leftIndex];
                    leftIndex++;
                }
                else
                {
                    array[newIndex] = copy[rightIndex];
                    rightIndex++;
                }
                newIndex++;
            }

            int remaining = middleIndex - leftIndex;
            for (int i = 0; i <= remaining; i++)
            {
                array[newIndex + i] = copy[leftIndex + i];
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="array"></param>
        public static void SelectionSort(ref int[] array)
        {
            for (int i = 0; i < array.Length; i++)
            {
                var lowestIndex = i;
                for (int j = i + 1; j < array.Length; j++)
                {
                    if (array[lowestIndex] > array[j])
                        lowestIndex = j;
                }
                var temp = array[i];
                array[i] = array[lowestIndex];
                array[lowestIndex] = temp;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="array"></param>
        public static void BubbleSort(ref int[] array)
        {
            for (int i = 0; i < array.Length; i++)
            {
                var current = 0;
                for (int j = 1; j < array.Length - i; j++)
                {
                    if (array[current] > array[j])
                    {
                        Swap(ref array, current, j);
                    }
                    current++;
                }
            }
        }

        //The idea behind a radix sort is you sort by the LSD by grouping into buckets and simply
        //storing the results from the buckets in order in the original array.
        //Continuing to sort until the MSD has been scanned and all entries are placed back in the array.
        //Each pass arranges the array values by the SD of that pass. You do NOT sort the individual buckets.
        /// <summary>
        /// 
        /// </summary>
        /// <param name="array"></param>
        public static void RadixHelper(ref int[] array)
        {
            //Get max value in the array
            var maxValue = 0;
            for (int i = 0; i < array.Length; i++)
            {
                if (maxValue < array[i])
                    maxValue = array[i];
            }

            //Get maximum precision
            var maxPrecision = 0;
            maxValue = maxValue / 10;
            while (maxValue > 0)
            {
                maxValue = maxValue / 10;
                maxPrecision++;
            }

            RadixSort(ref array, 0, maxPrecision);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="array"></param>
        /// <param name="precision"></param>
        /// <param name="maxPrecision"></param>
        private static void RadixSort(ref int[] array, int precision, int maxPrecision)
        {
            if (precision <= maxPrecision)
            {
                Dictionary<int, List<int>> hash = new Dictionary<int, List<int>>();

                for (int i = 0; i < array.Length; i++)
                {
                    int key = (array[i] / (int)Math.Pow(10, precision)) % 10;
                    if (hash.ContainsKey(key))
                        hash[key].Add(array[i]);
                    else
                        hash.Add(key, new List<int>() { array[i] });
                }

                var count = 0;
                for (int key = 0; key <= 9; key++)
                {
                    if (hash.ContainsKey(key))
                    {
                        var value = hash[key];
                        for (int i = 0; i < value.Count; i++)
                        {
                            array[count] = value[i];
                            count++;
                        }
                    }
                }

                RadixSort(ref array, ++precision, maxPrecision);
            }
        }

        //Similar to radix sort except the contents of the buckets are sorted before being placed back into the 
        //array.
        /// <summary>
        /// 
        /// </summary>
        /// <param name="array"></param>
        public static void BucketSort(ref int[] array)
        {
            Dictionary<int, List<int>> hash = new Dictionary<int, List<int>>();

            //Get max value
            var max = 0;
            for (int i = 0; i < array.Length; i++)
            {
                if (max < array[i])
                    max = array[i];
            }

            var bucketCount = 10;
            var bucketSize = Math.Max(1, max / bucketCount);

            //Create buckets based on the array
            for (int i = 0; i < array.Length; i++)
            {
                var key = array[i] / bucketSize;
                if (hash.ContainsKey(key))
                {
                    hash[key].Add(array[i]);
                }
                else
                {
                    hash[key] = new List<int>() { array[i] };
                }
            }

            //Sort each bucket
            foreach (int key in hash.Keys)
            {
                hash[key].OrderBy(p => p);
            }

            //Place all ordered from buckets back into list
            var count = 0;
            for (int i = 0; i <= (max / bucketSize); i++)
            {
                if (hash.ContainsKey(i))
                {
                    for (int j = 0; j < hash[i].Count; j++)
                    {
                        array[count] = hash[i][j];
                        count++;
                    }
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="array"></param>
        public static void CountingSort(ref int[] array)
        {
            //count all appearances of values, store by key
            //go through all values stored and set values to also their index offset
            //iterate through the values of the array again, this time you use the value of the count array to be the index

            Dictionary<int, int> hash = new Dictionary<int, int>();

            //Get count of each value in the array
            for (int i = 0; i < array.Length; i++)
            {
                if (hash.ContainsKey(array[i]))
                    hash[array[i]] += 1;
                else
                    hash.Add(array[i], 1);
            }

            //Sets the starting position of each index, from 0...k where k is the max value possible found in the array
            var position = 0;
            foreach (int key in hash.Keys.OrderBy(p => p))
            {
                var oldCount = hash[key];
                hash[key] = position;
                position += oldCount;
            }

            var output = new int[array.Length];
            //Sets the output for the array, the hash contains the index for the new array for each value found 
            //in the original array.
            for (int i = 0; i < array.Length; i++)
            {
                output[hash[array[i]]] = array[i];
                hash[array[i]] += 1;
            }

            array = output;
        }

        /// <summary>
        /// Requires the array to be sorted.
        /// </summary>
        /// <param name="value"></param>
        /// <param name="array"></param>
        /// <param name="minIndex"></param>
        /// <param name="maxIndex"></param>
        /// <returns></returns>
        public static int BinarySearch(int value, int[] array, int minIndex, int maxIndex)
        {
            if (maxIndex < 0 || minIndex < 0)
                throw new IndexOutOfRangeException();

            if (maxIndex <= minIndex)
                return -1;

            var midIndex = minIndex + (maxIndex - minIndex) / 2;
            if (array[midIndex] > value)
            {
                //search left
                return BinarySearch(value, array, minIndex, midIndex);
            }
            else if (array[midIndex] < value)
            {
                //search right
                return BinarySearch(value, array, midIndex + 1, maxIndex);
            }
            else
            {
                //value found
                return midIndex;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="value"></param>
        /// <param name="array"></param>
        /// <returns></returns>
        public static int LinearSearch(int value, int[] array)
        {
            for (int i = 0; i < array.Length; i++)
            {
                if (array[i] == value)
                    return i;
            }
            return -1;
        }
    }
}
