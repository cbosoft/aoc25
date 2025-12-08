import java.util.*;

public class Connection {
  public final Integer i;
  public final Integer j;
  public final Double distance;

  public Connection(Integer i, Integer j, Double distance) {
    this.i = i;
    this.j = j;
    this.distance = distance;
  }

}

public class Circuit {
  public final Integer i;
  public HashSet<Integer> box_indices;
  public Circuit(Integer i) {
    this.i = i;
    this.box_indices = new HashSet<Integer>();
  }

  public void add(JunctionBox box) {
    this.box_indices.add(box.i);
    box.circuit = this.i;
  }
}

public class JunctionBox {
  public final Integer i;
  public final Double x;
  public final Double y;
  public final Double z;
  public Integer circuit;

  public JunctionBox(Integer i, Double x, Double y, Double z) {
    this.i = i;
    this.x = x;
    this.y = y;
    this.z = z;
    this.circuit = -1;
  }
}

public class DecorationProject {
  public ArrayList<JunctionBox> boxes;
  public ArrayList<Circuit> circuits;
  public HashSet<Integer> free;
  public HashSet<Integer> connected;

  public ArrayList<Connection> possible_connections;

  public DecorationProject() {
    this.boxes = new ArrayList<JunctionBox>();
    this.free = new HashSet<Integer>();
    this.connected = new HashSet<Integer>();
    this.circuits = new ArrayList<Circuit>();
    this.possible_connections = new ArrayList<Connection>();
  }

  public void add(Double x, Double y, Double z) {
    Integer i = this.boxes.size();
    this.free.add(i);
    JunctionBox b = new JunctionBox(i, x, y, z);
    this.boxes.add(b);

    Circuit circuit = new Circuit(this.circuits.size());
    circuit.add(b);
    this.circuits.add(circuit);
  }

  public Double calc_distance(Integer i, Integer j) {
    JunctionBox b1 = this.boxes.get(i);
    JunctionBox b2 = this.boxes.get(j);
    Double dx2 = Math.pow(b2.x - b1.x, 2);
    Double dy2 = Math.pow(b2.y - b1.y, 2);
    Double dz2 = Math.pow(b2.z - b1.z, 2);
    return Math.pow(dx2 + dy2 + dz2, 0.5);
  }

  public void compute_distance_matrix() {
    Integer n = this.boxes.size();
    Double[][] distances = new Double[n][n];
    ArrayList<Connection> connections = new ArrayList<Connection>();
    for (Integer i = 0; i < n; i++) {
      for (Integer j = 0; j < i; j++) {
        Double distance = this.calc_distance(i, j);
        Connection conn = new Connection(i, j, distance);
        connections.add(conn);
      }
    }

    connections.sort((a, b) -> { return a.distance.compareTo(b.distance); });
    this.possible_connections = connections;
  }

  public Connection connect_one() {
    Connection next_conn = this.possible_connections.remove(0);
    JunctionBox boxi = this.boxes.get(next_conn.i);
    JunctionBox boxj = this.boxes.get(next_conn.j);
    this.free.remove(next_conn.i);
    this.free.remove(next_conn.j);
    if ((boxj.circuit < 0) && (boxi.circuit < 0)) {
      Circuit circuit = new Circuit(this.circuits.size());
      this.circuits.add(circuit);
      circuit.add(boxi);
      circuit.add(boxj);
      this.free.remove(next_conn.j.intValue());
    }
    else if (boxi.circuit == boxj.circuit) {
      // ??
    }
    else if ((boxi.circuit >= 0) && (boxj.circuit >= 0)) {
      Integer circuit_i = boxi.circuit;
      Integer circuit_j = boxj.circuit;
      Circuit circuit = this.circuits.get(circuit_i);
      Circuit defunct = this.circuits.get(circuit_j);
      for (Integer i: defunct.box_indices) {
        circuit.add(this.boxes.get(i));
      }
      defunct.box_indices.clear();
    }
    else {
      Integer circuit_i = Math.max(boxi.circuit, boxj.circuit);
      Circuit circuit = this.circuits.get(circuit_i);
      circuit.add(boxi);
    }

    // System.out.printf("num circuits: %d, num free: %d\n", nondefunct.size(), this.free.size());
    return next_conn;
  }

  public void remove_defunct() {
    this.circuits.removeIf((v) -> { return v.box_indices.size() == 0; });
  }
}

public class p2 {

  public static void main(String[] args) {
    Scanner scanner = new Scanner(System.in);
    DecorationProject project = new DecorationProject();

    while (true) {
      String line;
      try {
        line = scanner.nextLine();
      }
      catch (NoSuchElementException e) {
        break;
      }
      String[] parts = line.split(",");
      project.add(
        Double.parseDouble(parts[0]),
        Double.parseDouble(parts[1]),
        Double.parseDouble(parts[2])
      );
    }

    project.compute_distance_matrix();
    Connection conn = null;
    Integer n_circuits = project.circuits.size();
    Integer n_free = project.free.size();
    while ((n_circuits > 1) || (n_free > 0)) {
      conn = project.connect_one();
      ArrayList<Circuit> nondefunct = (ArrayList<Circuit>) project.circuits.clone();
      nondefunct.removeIf((v) -> { return v.box_indices.size() < 2; });
      n_circuits = nondefunct.size();
      n_free = project.free.size();
    }

    JunctionBox a = project.boxes.get(conn.i);
    JunctionBox b = project.boxes.get(conn.j);

    System.out.printf("lastconn: [%f, %f, %f]\n", a.x, a.y, a.z);
    System.out.printf("        : [%f, %f, %f]\n", b.x, b.y, b.z);
    System.out.printf("lastconn xprod: %f x %f = %f\n", a.x, b.x, a.x*b.x);
  }
}
