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

  Scenario: array elements may be initialized according to a parameter value
    Given a target source named "fixture.c" with:
      """
      extern void bar(const int *);

      void baz(int i)
      {
          int a[5];

          for (; i < 2; i++) {
              a[i] = i;
          }

          bar(a); /* OK not W0461 but W0462 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0534 | 7    | 10     |
      | W0705 | 8    | 11     |
      | C1000 |      |        |
      | C1006 | 3    | 14     |
      | W0462 | 11   | 9      |
      | C1000 |      |        |
      | C1003 | 5    | 9      |
      | C1002 | 7    | 14     |
      | W0950 | 5    | 11     |
      | W0628 | 3    | 6      |

  Scenario: array elements is initialized by an iteration-statement
    Given a target source named "fixture.c" with:
      """
      extern void bar(const int *);

      void baz(void)
      {
          int a[3];

          for (int i = 0; i < 3; i++) {
              a[i] = i;
          }

          bar(a); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0950 | 5    | 11     |
      | W0628 | 3    | 6      |
