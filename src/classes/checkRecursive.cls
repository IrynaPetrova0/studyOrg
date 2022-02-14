/**
 * Created by iryna.petrova on 12/14/2021.
 */

public class checkRecursive {
    private static Boolean run = true;
    public static Boolean runOnce() {
        if (run) {
            run = false;
            return true;
        } else {
            return run;
        }
    }
}