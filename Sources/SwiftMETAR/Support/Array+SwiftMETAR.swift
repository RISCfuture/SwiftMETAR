import Foundation

extension Array where Element == Substring {
  func removedItems(from original: [Substring]) -> [Substring] {
    var removedItems: [Substring] = []

    var originalIndex = original.endIndex
    var selfIndex = self.endIndex

    // Iterate from the end of both arrays
    while originalIndex != original.startIndex || selfIndex != self.startIndex {
      if selfIndex == self.startIndex {
        // If self array has reached its start, add remaining items from original array
        while originalIndex != original.startIndex {
          originalIndex = original.index(before: originalIndex)
          removedItems.append(original[originalIndex])
        }
        break
      }
      if originalIndex == original.startIndex {
        // If original array has reached its start, break
        break
      }
      originalIndex = original.index(before: originalIndex)
      selfIndex = self.index(before: selfIndex)

      // Compare elements at the current indices
      if self[selfIndex] != original[originalIndex] {
        // If elements are different, add the element from original array to removedItems
        removedItems.append(original[originalIndex])
      }
    }

    return removedItems.reversed()  // Reverse to maintain original order
  }
}
