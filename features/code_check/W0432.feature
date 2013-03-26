Feature: W0432

  W0432 detects that indentation of this line does not match with the project's
  indentation style.

  Scenario: function-like macro replacement
    Given a target source named "fixture.c" with:
      """
      extern int foo(int, int);

      #define bar(a, b) ((a) > 0) ? (a) : (b)
      #define baz(a, b) \
          ((a) > 0) ?   \
          (a) : (b)

      void qux(void)
      {
          int i = 0;

          i = foo(1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1,  /* OK */
                  2 + 2 + 2 + 2 + 2 + 2 + 2 + 2 + 2 + 2 + 2 + 2 + 2); /* OK */
          i = bar(1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1,  /* OK */
                  2 + 2 + 2 + 2 + 2 + 2 + 2 + 2 + 2 + 2 + 2 + 2 + 2); /* OK */
          i = baz(1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1,  /* OK */
                  2 + 2 + 2 + 2 + 2 + 2 + 2 + 2 + 2 + 2 + 2 + 2 + 2); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 3    | 1      |
      | W0442 | 4    | 1      |
      | W0118 | 1    | 12     |
      | W0117 | 8    | 6      |
      | W0609 | 14   | 9      |
      | W0609 | 16   | 9      |
      | W0443 | 3    | 1      |
      | W0443 | 4    | 1      |
      | W0628 | 8    | 6      |
