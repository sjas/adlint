Feature: W0461

  W0461 detects that a pointer to the undefined value is passed as an argument.

  Scenario: pointer to the global constant array initialized with a
            string-literal
    Given a target source named "fixture.c" with:
      """
      static const char str[] = "str";

      extern void foo(const void *);

      static void bar(void)
      {
          foo(str); /* OK */
      }

      static void baz(void)
      {
          foo(str); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 3    | 13     |
      | W1076 | 5    | 13     |
      | W1076 | 10   | 13     |
      | W0629 | 5    | 13     |
      | W0629 | 10   | 13     |
      | W0947 | 1    | 27     |
      | W0628 | 5    | 13     |
      | W0628 | 10   | 13     |

  Scenario: pointer to the global constant explicitly sized array initialized
            with a string-literal
    Given a target source named "fixture.c" with:
      """
      static const char str[4] = "str";

      extern void foo(const void *);

      static void bar(void)
      {
          foo(str); /* OK */
      }

      static void baz(void)
      {
          foo(str); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 3    | 13     |
      | W1076 | 5    | 13     |
      | W1076 | 10   | 13     |
      | W0629 | 5    | 13     |
      | W0629 | 10   | 13     |
      | W0947 | 1    | 28     |
      | W0950 | 1    | 23     |
      | W0628 | 5    | 13     |
      | W0628 | 10   | 13     |
