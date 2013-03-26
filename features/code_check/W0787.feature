Feature: W0787

  W0787 detects that a variable defined with a type which is different with one
  of previously defined variable in the other scope.

  Scenario: different types of local variables of the same name
    Given a target source named "fixture.c" with:
      """
      int foo(void)
      {
          int retval = 0;
          return retval;
      }

      long bar(void)
      {
          long retval = 0; /* OK */
          return retval;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0100 | 3    | 9      |
      | W0117 | 7    | 6      |
      | W0100 | 9    | 10     |
      | W0628 | 1    | 5      |
      | W0628 | 7    | 6      |

  Scenario: different types of `extern' variables of the same name
    Given a target source named "fixture.c" with:
      """
      void foo(void)
      {
          extern int retval;
          retval = 0;
      }

      void bar(void)
      {
          extern long retval; /* W0787 */
          retval = 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0118 | 3    | 16     |
      | W0623 | 3    | 16     |
      | W0117 | 7    | 6      |
      | W0118 | 9    | 17     |
      | W0623 | 9    | 17     |
      | W0787 | 9    | 17     |
      | C0001 | 3    | 16     |
      | W0628 | 1    | 6      |
      | W0628 | 7    | 6      |
      | W0770 | 3    | 16     |
      | C0001 | 9    | 17     |
      | W1037 | 3    | 16     |
      | C0001 | 9    | 17     |
      | W0770 | 9    | 17     |
      | C0001 | 3    | 16     |
      | W1037 | 9    | 17     |
      | C0001 | 3    | 16     |
