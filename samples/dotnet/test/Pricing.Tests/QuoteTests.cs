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
/// </summary>
public class QuoteTests
{
    /// <summary>The one path through <see cref="Quote.Price"/> the suite knows.</summary>
    [Fact]
    public void AGoldCustomerGetsTenPercent() =>
        Assert.Equal(90m, Quote.Price(100m, new Customer(Tier.Gold, Years: 2), lines: 2));

    /// <summary>Every kind of delivery, in both weight bands.</summary>
    /// <param name="kind">Kind of delivery.</param>
    /// <param name="weightKg">Parcel weight.</param>
    /// <param name="expected">The charge.</param>
    [Theory]
    [InlineData("standard", 1, 4.9)]
    [InlineData("standard", 25, 9.8)]
    [InlineData("express", 1, 12)]
    [InlineData("express", 25, 24)]
    [InlineData("pickup", 1, 0)]
    [InlineData("freight", 400, 80)]
    public void ShippingKnowsEveryKind(string kind, double weightKg, double expected) =>
        Assert.Equal((decimal)expected, Quote.Shipping(kind, (decimal)weightKg));

    /// <summary>The fallback of <see cref="Quote.Shipping"/> is tested too.</summary>
    [Fact]
    public void UnknownDeliveryIsRefused() =>
        Assert.Throws<ArgumentException>(() => Quote.Shipping("drone", 1m));

    /// <summary>Never a price below the minimum: the guard's return never runs.</summary>
    [Fact]
    public void APriceAboveTheMinimumIsKept() =>
        Assert.Equal(12m, Quote.AtLeast(12m, 5m));

    /// <summary>Only ever Switzerland: the other arm of the ternary never runs.</summary>
    [Fact]
    public void VatIsAddedForSwitzerland() =>
        Assert.Equal(108.1m, Quote.WithVat(100m, "CH"));
}
