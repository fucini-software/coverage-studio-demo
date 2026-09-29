// <copyright file="ShippingTests.cs" company="Fucini Consulting">
// Copyright (c) 2026 Fucini Consulting. Released under the MIT License; see the
// LICENSE file in the repository root.
// </copyright>
// <author>Mario Fucini</author>

using Xunit;

namespace Pricing.Tests;

/// <summary>
/// The shipping tests, in a class of their own: a second test class is what
/// makes the per-test reports (<c>coverage/per-test/</c>) say something —
/// <em>Show Tests That Ran This Line</em> names this class on
/// <see cref="Quote.Shipping"/> and <see cref="QuoteTests"/> on
/// <see cref="Quote.Price"/>.
/// </summary>
public class ShippingTests
{
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
}
