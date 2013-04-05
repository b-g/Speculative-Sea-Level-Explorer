//http://stackoverflow.com/questions/9668821/array-interpolation

public static class CubicInterpolator {
    public static double getValue(double[] p, double x) {
        int xi = (int) x;
        x -= xi;
        double p0 = p[Math.max(0, xi - 1)];
        double p1 = p[xi];
        double p2 = p[Math.min(p.length - 1,xi + 1)];
        double p3 = p[Math.min(p.length - 1, xi + 2)];
        return p1 + 0.5 * x * (p2 - p0 + x * (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3 + x * (3.0 * (p1 - p2) + p3 - p0)));
    }
    public static float getValue(float[] p, float x) {
        int xi = (int) x;
        x -= xi;
        float p0 = p[Math.max(0, xi - 1)];
        float p1 = p[xi];
        float p2 = p[Math.min(p.length - 1,xi + 1)];
        float p3 = p[Math.min(p.length - 1, xi + 2)];
        return p1 + 0.5 * x * (p2 - p0 + x * (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3 + x * (3.0 * (p1 - p2) + p3 - p0)));
    }
    public static int getValue(int[] p, int x) {
        int xi = x;
        x -= xi;
        int p0 = p[Math.max(0, xi - 1)];
        int p1 = p[xi];
        int p2 = p[Math.min(p.length - 1,xi + 1)];
        int p3 = p[Math.min(p.length - 1, xi + 2)];
        return Math.round( p1 + 0.5 * x * (p2 - p0 + x * (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3 + x * (3.0 * (p1 - p2) + p3 - p0))) );
    }
}

public static class BicubicInterpolator extends CubicInterpolator {
    public static double getValue(double[][] p, double x, double y) {
        double[] arr = new double[4];
        int xi = (int) x;
        x -= xi;
        arr[0] = getValue(p[Math.max(0, xi - 1)], y);
        arr[1] = getValue(p[xi], y);
        arr[2] = getValue(p[Math.min(p.length - 1,xi + 1)], y);
        arr[3] = getValue(p[Math.min(p.length - 1, xi + 2)], y);
        return getValue(arr, x+ 1);
    }
    public static float getValue(float[][] p, float x, float y) {
        float[] arr = new float[4];
        int xi = (int) x;
        x -= xi;        
        arr[0] = getValue(p[Math.max(0, xi - 1)], y);
        arr[1] = getValue(p[xi], y);
        arr[2] = getValue(p[Math.min(p.length - 1,xi + 1)], y);
        arr[3] = getValue(p[Math.min(p.length - 1, xi + 2)], y);
        return getValue(arr, x+ 1);
    }
    public static int getValue(int[][] p, int x, int y) {
        int[] arr = new int[4];
        int xi = x;
        x -= xi;
        arr[0] = getValue(p[Math.max(0, xi - 1)], y);
        arr[1] = getValue(p[xi], y);
        arr[2] = getValue(p[Math.min(p.length - 1,xi + 1)], y);
        arr[3] = getValue(p[Math.min(p.length - 1, xi + 2)], y);
        return getValue(arr, x+ 1);
    }
}
