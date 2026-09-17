// <copyright file="Quote.cs" company="Fucini Consulting">
// Copyright (c) 2026 Fucini Consulting. Released under the MIT License; see the
// LICENSE file in the repository root.
// </copyright>
// <author>Mario Fucini</author>

using System.Diagnostics.CodeAnalysis;

namespace Pricing;

/// <summary>Loyalty tier of a customer.</summary>
public enum Tier
{
    /// <summary>No discount.</summary>
    Basic,

    /// <summary>Five percent off.</summary>
    Silver,

    /// <summary>Ten percent off.</summary>
    Gold,

    /// <summary>Thirty percent off.</summary>
    Staff,
}

/// <summary>Who is buying.</summary>
/// <param name="Tier">Loyalty tier.</param>
/// <param name="Years">Years as a customer.</param>
/// <param name="Blocked">Set by accounts when nothing may be sold.</param>
/// <param name="Overdue">Whether an invoice is unpaid.</param>
public record Customer(Tier Tier, int Years, bool Blocked = false, bool Overdue = false);

/// <summary>
/// Pricing rules of the .NET coverage sample.
/// </summary>
/// <remarks>
/// OpenCover and Coverlet report a cyclomatic complexity per method, which is
/// what this sample is for: <see cref="Price"/> is complex and barely tested,
/// so its CRAP score is far above 30 and it heads the Riskiest Methods table;
/// <see cref="Shipping"/> is just as complex and fully tested, so its CRAP
/// score is its complexity and nothing more.
/// </remarks>
public static class Quote
{
    /// <summary>The price after every rule the business ever asked for.</summary>
    /// <param name="amount">The goods total.</param>
    /// <param name="customer">Who is buying.</param>
    /// <param name="lines">How many lines the order has.</param>
    /// <returns>The price to charge, never below zero.</returns>
    /// <exception cref="InvalidOperationException">The order needs manual approval.</exception>
    /// <remarks>
    /// Deliberately under-tested: the suite walks through it exactly one way, as
    /// a gold customer with a small order. High complexity, low coverage.
    /// </remarks>
    public static decimal Price(decimal amount, Customer customer, int lines)
    {
        var price = amount;

        if (customer.Tier == Tier.Gold)
        {
            price *= 0.9m;
        }
        else if (customer.Tier == Tier.Silver)
        {
            price *= 0.95m;
        }
        else if (customer.Tier == Tier.Staff)
        {
            price *= 0.7m;
        }

        if (customer.Years > 5 && customer.Tier != Tier.Staff)
        {
            price -= 5m;
        }

        if (lines >= 10)
        {
            price *= 0.97m;
        }
        else if (lines >= 5)
        {
            price *= 0.99m;
        }

        if (customer.Blocked || (customer.Overdue && amount > 500m))
        {
            throw new InvalidOperationException("order needs approval");
        }

        if (price < 0m)
        {
            price = 0m;
        }

        return price;
    }

    /// <summary>What delivery costs.</summary>
    /// <param name="kind"><c>standard</c>, <c>express</c>, <c>pickup</c> or <c>freight</c>.</param>
    /// <param name="weightKg">Weight of the parcel.</param>
    /// <returns>The charge.</returns>
    /// <exception cref="ArgumentException">An unknown kind of delivery.</exception>
    /// <remarks>
    /// Deliberately fully tested, every case and both weight bands: as complex
    /// as <see cref="Price"/>, and no risk at all.
    /// </remarks>
    public static decimal Shipping(string kind, decimal weightKg)
    {
        var heavy = weightKg > 20m;
        switch (kind)
        {
            case "standard":
                return heavy ? 9.8m : 4.9m;
            case "express":
                return heavy ? 24m : 12m;
            case "pickup":
                return 0m;
            case "freight":
                return 80m;
            default:
                throw new ArgumentException($"unknown delivery: {kind}", nameof(kind));
        }
    }

    /// <summary>Swiss VAT, when the order ships there.</summary>
    /// <param name="amount">The amount before tax.</param>
    /// <param name="country">ISO country code.</param>
    /// <returns>The amount with tax, rounded to cents.</returns>
    /// <remarks>
    /// One line, two outcomes: every test order ships to <c>CH</c>, so the
    /// second arm of the ternary never runs on a line that does.
    /// </remarks>
    public static decimal WithVat(decimal amount, string country) =>
        Math.Round(country == "CH" ? amount * 1.081m : amount, 2);

    /// <summary>Never charge less than a minimum.</summary>
    /// <param name="price">The computed price.</param>
    /// <param name="minimum">The least the shop charges.</param>
    /// <returns><paramref name="price"/>, or <paramref name="minimum"/> when it is lower.</returns>
    /// <remarks>
    /// The guard and its <c>return</c> share a line, and no test price is below
    /// the minimum: the line runs, the <c>return minimum;</c> on it never does.
    /// A collector with columns (dotnet-coverage) shows exactly that part in red.
    /// </remarks>
    public static decimal AtLeast(decimal price, decimal minimum)
    {
        if (price < minimum) return minimum;
        return price;
    }

    /// <summary>Format an invoice number. Never called by any test.</summary>
    /// <param name="year">Four-digit year.</param>
    /// <param name="serial">Running number within the year.</param>
    /// <returns>For example <c>2026-000042</c>.</returns>
    public static string InvoiceNumber(int year, int serial) => $"{year}-{serial:D6}";

    /// <summary>Print a quote. Excluded from measurement on purpose: a developer aid.</summary>
    /// <param name="amount">The amount to print.</param>
    [ExcludeFromCodeCoverage]
    public static void DebugDump(decimal amount) => Console.WriteLine($"quote: {amount}");
}
