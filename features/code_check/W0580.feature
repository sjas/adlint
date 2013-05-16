Feature: W0580

  W0580 detects that address of the function local static variable is assigned
  to the global pointer variable declared in wider scope.

  Scenario: assigning address of an array element to the global pointer
    Given a target source named "fixture.c" with:
      """
      extern int *p;

      static void foo(void)
      {
          static int a[] = { 1, 2, 3 };
          p = &a[1]; /* W0580 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W1076 | 3    | 13     |
      | W0580 | 6    | 7      |
      | W0100 | 5    | 16     |
      | W0629 | 3    | 13     |
      | W0628 | 3    | 13     |
