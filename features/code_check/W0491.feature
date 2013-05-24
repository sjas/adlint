Feature: W0491

  W0491 detects that the same name appears in different namespaces.

  Scenario: hard to parse
    Given a target source named "fixture.c" with:
      """
      typedef struct named_ref {
          int id;
      } named_ref; /* W0491 */

      typedef struct code_props {
          named_ref *named_ref; /* W0492 */
      } code_props; /* W0491 */

      void func(named_ref *named_ref);
      void bar(int, named_ref *, named_ref *);
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0491 | 3    | 3      |
      | C0001 | 1    | 16     |
      | W0492 | 6    | 16     |
      | C0001 | 3    | 3      |
      | C0001 | 1    | 16     |
      | W0491 | 7    | 3      |
      | C0001 | 5    | 16     |
      | W0118 | 9    | 6      |
      | W0118 | 10   | 6      |
