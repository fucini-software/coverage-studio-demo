// <copyright file="QuoteTests.cs" company="Fucini Consulting">
// Copyright (c) 2026 Fucini Consulting. Released under the MIT License; see the
// LICENSE file in the repository root.
// </copyright>
// <author>Mario Fucini</author>

using Xunit;

namespace Pricing.Tests;

/// <summary>
/// The test suite of the .NET coverage sample. What it never passes in is
/// deliberate, and is documented on the method it belongs to in Quote.cs.
/// The shipping tests are in <see cref="ShippingTests"/>, so that the
/// per-test reports have two classes to tell apart.
/// </summary>
public class QuoteTests
{
    /// <summary>The one path through <see cref="Quote.Price"/> the suite knows.</summary>
    [Fact]
    public void AGoldCustomerGetsTenPercent() =>
        Assert.Equal(90m, Quote.Price(100m, new Customer(Tier.Gold, Years: 2), lines: 2));

    /// <summary>Never a price below the minimum: the guard's return never runs.</summary>
    [Fact]
    public void APriceAboveTheMinimumIsKept() =>
        Assert.Equal(12m, Quote.AtLeast(12m, 5m));

    /// <summary>Only ever Switzerland: the other arm of the ternary never runs.</summary>
    [Fact]
    public void VatIsAddedForSwitzerland() =>
        Assert.Equal(108.1m, Quote.WithVat(100m, "CH"));
}
