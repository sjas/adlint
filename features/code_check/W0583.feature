Feature: W0583

  W0583 detects that arguments specified to call the function does not match
  with the corresponding function-definition appears after the function-call.

  Scenario: array as an argument
    Given a target source named "fixture.c" with:
      """
      int main(void)
      {
          int a[] = { 0, 1, 2 };
          return foo(a);
      }

      int foo(const int *p) { /* W0583 should not be output */
          return *p;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0109 | 4    | 12     |
      | W0117 | 7    | 5      |
      | W0422 | 8    | 12     |
      | W0104 | 7    | 20     |
      | W0589 | 7    | 5      |
      | W0591 | 7    | 5      |

  Scenario: call with matched arguments
    Given a target source named "fixture.c" with:
      """
      static void foo(int *p)
      {
          bar(NULL, *p); /* OK */
      }

      static void bar(int *p, int i)
      {
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0422 | 3    | 15     |
      | W0109 | 3    | 5      |
      | W0104 | 1    | 22     |
      | W0105 | 1    | 22     |
      | W1073 | 3    | 8      |
      | W1076 | 6    | 13     |
      | W0031 | 6    | 22     |
      | W0031 | 6    | 29     |
      | W0104 | 6    | 22     |
      | W0104 | 6    | 29     |
      | W0105 | 6    | 22     |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |

  Scenario: call with unmatched arguments
    Given a target source named "fixture.c" with:
      """
      static void foo(int *p)
      {
          bar(NULL, p); /* W0583 */
      }

      static void bar(int *p, int i)
      {
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0109 | 3    | 5      |
      | W0104 | 1    | 22     |
      | W0105 | 1    | 22     |
      | W1073 | 3    | 8      |
      | W0583 | 3    | 8      |
      | W1076 | 6    | 13     |
      | W0031 | 6    | 22     |
      | W0031 | 6    | 29     |
      | W0104 | 6    | 22     |
      | W0104 | 6    | 29     |
      | W0105 | 6    | 22     |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |

  Scenario: call with unmatched constant pointer
    Given a target source named "fixture.c" with:
      """
      static void foo(int *p)
      {
          bar(3, p); /* W0583 */
      }

      static void bar(int *p, int i)
      {
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0109 | 3    | 5      |
      | W0104 | 1    | 22     |
      | W0105 | 1    | 22     |
      | W1073 | 3    | 8      |
      | W0583 | 3    | 8      |
      | W1076 | 6    | 13     |
      | W0031 | 6    | 22     |
      | W0031 | 6    | 29     |
      | W0104 | 6    | 22     |
      | W0104 | 6    | 29     |
      | W0105 | 6    | 22     |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |
