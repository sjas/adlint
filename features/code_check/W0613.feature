Feature: W0613

  W0613 detects that a controlling expression of the iteration-statement always
  be false.

  Scenario: array-subscript-expression refers to global constant table
    Given a target source named "fixture.c" with:
      """
      static const int a[256] = { 0, 1, 0, 0, 1 };

      extern unsigned char foo(int);

      int main(void)
      {
          int i, j = 0;

          for (i = 0; a[foo(i)]; i++) { /* OK */
              j++;
          }

          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 3    | 22     |
      | W0246 | 9    | 22     |
      | W0736 | 1    | 18     |
      | W0043 | 1    | 27     |
      | W0950 | 1    | 20     |
      | W0114 | 9    | 5      |
      | W0425 | 7    | 12     |
