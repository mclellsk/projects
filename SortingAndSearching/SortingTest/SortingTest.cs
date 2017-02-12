using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using SortLibrary;

namespace SortingTest
{
    [TestClass]
    public class SortingTest
    {
        [TestMethod]
        public void TestSort_SortedArray()
        {
            int[] array = new int[] { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
            int[] arrayExpectedResult = new int[] { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };

            TestSorts(array, arrayExpectedResult);
        }
        [TestMethod]
        public void TestSort_EmptyArray()
        {
            int[] array = new int[] { };
            int[] arrayExpectedResult = new int[] { };

            TestSorts(array, arrayExpectedResult);
        }
        [TestMethod]
        public void TestSort_OddSizedArray()
        {
            int[] array = new int[] { 2, 8, 7, 1, 3, 0, 4, 6, 5 };
            int[] arrayExpectedResult = new int[] { 0, 1, 2, 3, 4, 5, 6, 7, 8 };

            TestSorts(array, arrayExpectedResult);
        }
        [TestMethod]
        public void TestSort_EvenSizedArray()
        {
            int[] array = new int[] { 8, 2, 9, 7, 5, 0, 4, 3, 6, 1 };
            int[] arrayExpectedResult = new int[] { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };

            TestSorts(array, arrayExpectedResult);
        }
        [TestMethod]
        public void TestSort_RotatedHalfArray()
        {
            int[] array = new int[] { 5, 6, 7, 8, 9, 0, 1, 2, 3, 4 };
            int[] arrayExpectedResult = new int[] { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };

            TestSorts(array, arrayExpectedResult);
        }

        public void TestSorts(int[] array, int[] expected)
        {
            BubbleSortTest(array, expected);
            MergeSortTest(array, expected);
            QuickSortTest(array, expected);
            SelectionSortTest(array, expected);
            RadixSortTest(array, expected);
            CountingSortTest(array, expected);
            BucketSortTest(array, expected);
        }
        public void MergeSortTest(int[] array, int[] expected)
        {
            var temp = array;
            Sorter.MergeSort(ref temp, 0, temp.Length - 1);
            CollectionAssert.AreEqual(expected, temp);
        }
        public void BubbleSortTest(int[] array, int[] expected)
        {
            var temp = array;
            Sorter.BubbleSort(ref temp);
            CollectionAssert.AreEqual(expected, temp);
        }
        public void QuickSortTest(int[] array, int[] expected)
        {
            var temp = array;
            Sorter.QuickSort(ref temp, 0, temp.Length - 1);
            CollectionAssert.AreEqual(expected, temp);
        }
        public void RadixSortTest(int[] array, int[] expected)
        {
            var temp = array;
            Sorter.RadixHelper(ref temp);
            CollectionAssert.AreEqual(expected, temp);
        }
        public void CountingSortTest(int[] array, int[] expected)
        {
            var temp = array;
            Sorter.CountingSort(ref temp);
            CollectionAssert.AreEqual(expected, temp);
        }
        public void BucketSortTest(int[] array, int[] expected)
        {
            var temp = array;
            Sorter.BucketSort(ref temp);
            CollectionAssert.AreEqual(expected, temp);
        }
        public void SelectionSortTest(int[] array, int[] expected)
        {
            var temp = array;
            Sorter.SelectionSort(ref temp);
            CollectionAssert.AreEqual(expected, temp);
        }
    }
}
