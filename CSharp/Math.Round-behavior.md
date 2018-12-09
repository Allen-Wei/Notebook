ref: [Why does Math.Round(2.5) return 2 instead of 3?](https://stackoverflow.com/questions/977796/why-does-math-round2-5-return-2-instead-of-3)

```csharp
double dbl1 = Math.Round(1.5); // dbl1 == 2
double dbl2 = Math.Round(2.5); // dbl2 == 2
double dbl3 = Math.Round(2.5, 0, MidpointRounding.AwayFromZero); // dbl3 == 3
```