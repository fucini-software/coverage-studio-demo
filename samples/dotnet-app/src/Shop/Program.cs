// <copyright file="Program.cs" company="Fucini Consulting">
// Copyright (c) 2026 Fucini Consulting. Released under the MIT License; see the
// LICENSE file in the repository root.
// </copyright>
// <author>Mario Fucini</author>

using System;

namespace Shop;

/// <summary>
/// A console app with no tests at all: the sample for <em>Run App with
/// Coverage</em>, which measures what a person reaches by running the program,
/// not what a suite reaches. Started as it is, it prices three orders and
/// exits; what a run never does — a discount above a hundred, a refund — stays
/// red afterwards.
/// </summary>
public static class Program
{
    /// <summary>Price three orders and print them.</summary>
    /// <param name="args">Ignored.</param>
    /// <returns>Always zero.</returns>
    public static int Main(string[] args)
    {
        foreach (var amount in new[] { 40m, 75m, 99m })
        {
            Console.WriteLine($"Order of {amount}: {Price(amount)}");
        }

        return 0;
    }

    /// <summary>The price to charge: ten percent off above a hundred.</summary>
    /// <param name="amount">The order's total.</param>
    /// <returns>The amount, discounted where it qualifies.</returns>
    public static decimal Price(decimal amount)
    {
        if (amount > 100m)
        {
            return amount * 0.9m;
        }

        return amount;
    }

    /// <summary>What a cancelled order gives back. Never reached by a plain run.</summary>
    /// <param name="amount">The amount paid.</param>
    /// <returns>The amount, negated.</returns>
    public static decimal Refund(decimal amount)
    {
        return -amount;
    }
}
