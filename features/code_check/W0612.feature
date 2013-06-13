Feature: W0612

  W0612 detects that a controlling expression of the selection-statement always
  be true.

  Scenario: bitwise and expression as the controlling expression
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int ui)
      {
          while (ui) {
              if (ui & 1) { /* OK not W0612 */
                  break;
              }
              else {
                  ui >>= 1;
              }
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0167 | 4    | 18     |
      | W0572 | 4    | 16     |
      | W0114 | 3    | 5      |
      | W0114 | 4    | 9      |
      | W0628 | 1    | 6      |
