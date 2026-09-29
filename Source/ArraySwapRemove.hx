class ArraySwapRemove {
    public static inline function swapRemoveAt<T>(arr:Array<T>, index:Int):T {
        var last = arr.pop();
        if (index < arr.length) {
            var removed = arr[index];
            arr[index] = last;
            return removed;
        }
        return last;
    }
}
