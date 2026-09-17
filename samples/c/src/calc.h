/**
 * @file calc.h
 * @brief Arithmetic and decision helpers of the C coverage sample.
 *
 * Every function here exists to leave one particular state behind once
 * calc_test.c has run: fully covered, partially covered, MC/DC satisfied, or
 * never called. The README in the repository root says which is which.
 *
 * @author Mario Fucini
 * @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
 *            License; see the LICENSE file in the repository root.
 */
#ifndef CALC_H
#define CALC_H

/**
 * @brief Add two integers.
 * @param a First operand.
 * @param b Second operand.
 * @return The sum @p a + @p b.
 */
int add(int a, int b);

/**
 * @brief Subtract one integer from another.
 * @param a Minuend.
 * @param b Subtrahend.
 * @return The difference @p a - @p b.
 */
int subtract(int a, int b);

/**
 * @brief Classify a number by its sign.
 * @param x The number to classify.
 * @retval 1  @p x is greater than zero.
 * @retval -1 @p x is zero or negative.
 * @note Partially covered on purpose: the suite only passes a positive value,
 *       so the @c else arm never runs.
 */
int classify(int x);

/**
 * @brief Evaluate the compound decision <tt>(a && b) || c</tt>.
 * @param a First condition.
 * @param b Second condition.
 * @param c Third condition.
 * @retval 1 The decision is true.
 * @retval 0 The decision is false.
 * @note MC/DC satisfied on purpose: the suite shows each of the three
 *       conditions changing the outcome on its own.
 */
int gate(int a, int b, int c);

/**
 * @brief Double a number.
 * @param x The number to double.
 * @return Twice @p x.
 * @note Never called by any test, on purpose: this is the dead code the
 *       never-called table and the 0% CodeLens are demonstrated on.
 */
int unused_helper(int x);

#endif /* CALC_H */
