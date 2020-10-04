import "package:test/test.dart";
import 'package:dartz/dartz.dart';
import 'laws.dart';
import 'proptest/PropTest.dart';

void main() {
  final pt = new PropTest();
  final intLists = Gen.listOf(Gen.ints);
  final simpleIntSets = intLists.map((il) => new ISet<int>.fromIList(IntOrder, ilist(il)));
  final intSets = simpleIntSets.flatMap((a) => simpleIntSets.flatMap((b) => simpleIntSets.map((c) => a + b + c)));

  test("insertion", () {
    pt.check(forAll(intLists)((l) {
      return ilist(l.toSet().toList()..sort()) == iset(l).toIList();
    }));
  });

  test("deletion", () {
    pt.check(forAll2(intLists, intLists)((l1, l2) {
      final actual = l2.fold<ISet<int>>(iset(l1), (s, i) => s.remove(i)).toIList();
      final expected = ilist(l1.where((i) => !l2.contains(i)).toSet().toList()..sort());
      return actual == expected;
    }));
  });

  test("demo", () {
    final ISet<String> s = iset(["row", "row", "row", "your", "boat"]);

    expect(s.contains("row"), true);
    expect(s.contains("paddle"), false);
    expect(s, iset(["row", "your", "boat"]));
  });

  group("ISetMonoid", () => checkMonoidLaws(new ISetMonoid(IntOrder), intSets));

  group("ISetTreeFo", () => checkFoldableLaws(ISetFo, intSets));

  group("ISet FoldableOps", () => checkFoldableOpsProperties(intSets));

  test("iterable", () => pt.check(forAll(intSets)((s) {
    return s.toIList() == ilist(s.toIterable());
  })));

  test("filter", () => pt.check(forAll(intSets)((intSet) {
    final positives = intSet.filter((i) => i >= 0);
    final negatives = intSet.filter((i) => i < 0);
    final allElementsRepresented = negatives.length() + positives.length() == intSet.length();
    final correctSubsets = positives.all((i) => i >= 0) && negatives.all((i) => i < 0);
    return allElementsRepresented && correctSubsets;
  })));

  test("partition", () => pt.check(forAll(intSets)((intSet) {
    final positivesAndNegatives = intSet.partition((i) => i >= 0);
    final positives = positivesAndNegatives.value1;
    final negatives = positivesAndNegatives.value2;
    final allElementsRepresented = negatives.length() + positives.length() == intSet.length();
    final correctSubsets = positives.all((i) => i >= 0) && negatives.all((i) => i < 0);
    return allElementsRepresented && correctSubsets;
  })));

  test("transform", () => pt.check(forAll(intSets)((intSet) {
    final positives = intSet.filter((i) => i >= 0);
    final sum = positives.concatenate(IntSumMi);
    final doubledPositives = positives.transform(IntOrder, (i) => i*2);
    final doubledSum = doubledPositives.concatenate(IntSumMi);
    return doubledSum == sum*2;
  })));

  test("isEmpty", () => pt.check(forAll(intSets)((s) => (s.length() == 0) == s.isEmpty)));

}
