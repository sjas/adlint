extern int foo(int);

void bar1(void)
{
    const int i = 1;
    const int j = 2;
    const int k = 3;
    const int * const p = &i;
    int r;

    r = i + j % k;
    r = i % j % k;
    r = i % j * k;
    r = i * j % k;

    r = foo(i + j % k);
    r = foo(i + j % foo(i + j % k));

    r = i << j >> k;
    r = i < j > k;
    r = i == j != k;

    r = i + j * k;
    r = i / j - k;

    r = i ? j : k;
    r = -i ? j : k;
    r = i ? -j : k;

    r = i > j ? j : k;
    r = i + j ? j : k;
    r = i ? j + k : k;
    r = i ? j : j + k;

    r = i + j >> k;
    r = i < j + k;
    r = i & j != k;

    i && -j;

    r = i && ~j;
    r = !i || j;
    r = *p || j;
    r = i && (unsigned int) j;

    r = i && j && k;
    r = i || j || k;
    r = i || j && i;
    r = i > j && k;
    r = i && j != k;

    r = i ? j : k ? i : j;
    r = i ? j ? k : j : i;

    r = i <= j <= k;
    r = i == j == k;
    r = i << j << k;
}

void bar2(void)
{
    const int i = 1;
    const int j = 2;
    const int k = 3;
    const int * const p = &i;
    int r;

    r = i + (j % k);
    r = (i % j) % k;
    r = (i % j) * k;
    r = (i * j) % k;

    r = foo(i + (j % k));
    r = foo(i + (j % foo(i + (j % k))));

    r = (i << j) >> k;
    r = (i < j) > k;
    r = (i == j) != k;

    r = i + (j * k);
    r = (i / j) - k;

    r = (i > j) ? j : k;
    r = (i + j) ? j : k;
    r = i ? (j + k) : k;
    r = i ? j : (j + k);

    r = (i + j) >> k;
    r = i < (j + k);
    r = i & (j != k);

    r = i && (~j);
    r = (!i) || j;
    r = (*p) || j;
    r = i && ((unsigned int) j);

    r = (i || j) && i;
    r = (i > j) && k;
    r = i && (j != k);

    r = i ? j : (k ? i : j);
    r = i ? (j ? k : j) : i;

    r = (i <= j) <= k;
    r = (i == j) == k;
    r = (i << j) << k;
}

void baz1(void)
{
    const int i = 1;
    const int j = 2;
    const int k = 3;
    const int * const p = &i;

    { const int r = i + j % k; }
    { const int r = i % j % k; }
    { const int r = i % j * k; }
    { const int r = i * j % k; }

    { const int r = foo(i + j % k); }
    { const int r = foo(i + j % foo(i + j % k)); }

    { const int r = i << j >> k; }
    { const int r = i < j > k; }
    { const int r = i == j != k; }

    { const int r = i + j * k; }
    { const int r = i / j - k; }

    { const int r = i ? j : k; }
    { const int r = -i ? j : k; }
    { const int r = i ? -j : k; }

    { const int r = i > j ? j : k; }
    { const int r = i + j ? j : k; }
    { const int r = i ? j + k : k; }
    { const int r = i ? j : j + k; }

    { const int r = i + j >> k; }
    { const int r = i < j + k; }
    { const int r = i & j != k; }

    { const int r = i && ~j; }
    { const int r = !i || j; }
    { const int r = *p || j; }
    { const int r = i && (unsigned int) j; }

    { const int r = i && j && k; }
    { const int r = i || j || k; }
    { const int r = i || j && i; }
    { const int r = i > j && k; }
    { const int r = i && j != k; }

    { const int r = i ? j : k ? i : j; }
    { const int r = i ? j ? k : j : i; }

    { const int r = i <= j <= k; }
    { const int r = i == j == k; }
    { const int r = i << j << k; }
}

void baz2(void)
{
    const int i = 1;
    const int j = 2;
    const int k = 3;
    const int * const p = &i;

    { const int r = i + (j % k); }
    { const int r = (i % j) % k; }
    { const int r = (i % j) * k; }
    { const int r = (i * j) % k; }

    { const int r = foo(i + (j % k)); }
    { const int r = foo(i + (j % foo(i + (j % k)))); }

    { const int r = (i << j) >> k; }
    { const int r = (i < j) > k; }
    { const int r = (i == j) != k; }

    { const int r = i + (j * k); }
    { const int r = (i / j) - k; }

    { const int r = (i > j) ? j : k; }
    { const int r = (i + j) ? j : k; }
    { const int r = i ? (j + k) : k; }
    { const int r = i ? j : (j + k); }

    { const int r = (i + j) >> k; }
    { const int r = i < (j + k); }
    { const int r = i & (j != k); }

    { const int r = i && (~j); }
    { const int r = (!i) || j; }
    { const int r = (*p) || j; }
    { const int r = i && ((unsigned int) j); }

    { const int r = (i || j) && i; }
    { const int r = (i > j) && k; }
    { const int r = i && (j != k); }

    { const int r = i ? j : (k ? i : j); }
    { const int r = i ? (j ? k : j) : i; }

    { const int r = (i <= j) <= k; }
    { const int r = (i == j) == k; }
    { const int r = (i << j) << k; }
}

void qux1(void)
{
    const int i = 1;
    const int j = 2;
    const int a[5] = {0};
    const struct { int m; } s = {0}, * const p = &s;
    int r;

    r = a[i] && j;
    r = foo(i) || j;
    r = p->m && i;
    r = s.m || i;
}

void qux2(void)
{
    const int i = 1;
    const int j = 2;
    const int a[5] = {0};
    const struct { int m; } s = {0}, * const p = &s;
    int r;

    r = (a[i]) && j;
    r = (foo(i)) || j;
    r = (p->m) && i;
    r = (s.m) || i;
}

void quux1(void)
{
    const int i = 1;
    const int j = 2;
    const int a[5] = {0};
    const struct { int m; } s = {0}, * const p = &s;

    { const int r = a[i] && j; }
    { const int r = foo(i) || j; }
    { const int r = p->m && i; }
    { const int r = s.m || i; }
}

void quux2(void)
{
    const int i = 1;
    const int j = 2;
    const int a[5] = {0};
    const struct { int m; } s = {0}, * const p = &s;

    { const int r = (a[i]) && j; }
    { const int r = (foo(i)) || j; }
    { const int r = (p->m) && i; }
    { const int r = (s.m) || i; }
}

void foobar1(void)
{
    const int i = 1;
    const int j = 2;
    const int k = 3;
    int r;

    r = i * j / k;
    r = i / j * k;
    r = i + j - k;
    r = i - j + k;
}

void foobar2(void)
{
    const int i = 1;
    const int j = 2;
    const int k = 3;
    int r;

    r = (i * j) / k;
    r = (i / j) * k;
    r = (i + j) - k;
    r = (i - j) + k;
}
