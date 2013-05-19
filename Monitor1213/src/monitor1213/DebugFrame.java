package monitor1213;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.Toolkit;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import javax.swing.JDialog;
import javax.swing.JPanel;
import javax.swing.JRootPane;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;

/**
 * 
 * @author Minetti Alberto
 */
public class DebugFrame extends JDialog {

	private static final long serialVersionUID = -4026165797297769412L;
	private static DebugFrame df;
	private JPanel jContentPane = null;
	private JTextArea jTextArea = null;
	private JScrollPane jScrollPane = null;

	private DebugFrame() {
		super(null, "Debug Frame", ModalityType.MODELESS);
		initialize();
	}


	private void initialize() {
		this.setDefaultCloseOperation(DO_NOTHING_ON_CLOSE);
		this.setSize(600, 200);
		Dimension dim = Toolkit.getDefaultToolkit().getScreenSize();
		this.setLocation(dim.width - this.getWidth(), dim.height - this.getHeight() - 40);
		this.setContentPane(getJContentPane());
		this.setTitle("Debug Frame");
		this.setUndecorated(true);
		this.getRootPane().setWindowDecorationStyle(JRootPane.ERROR_DIALOG);
		this.addWindowListener(new WindowAdapter() {
			@Override
			public void windowClosing(WindowEvent arg0) {
				System.exit(32);
			}
		});
		this.repaint();
		this.setVisible(true);
	}


	private JPanel getJContentPane() {
		if (jContentPane == null) {
			jContentPane = new JPanel();
			jContentPane.setLayout(new BorderLayout());
			jContentPane.add(getJScrollPane(), BorderLayout.CENTER); // Generated
		}
		return jContentPane;
	}


	private JTextArea getjTextArea() {
		if (jTextArea == null) {
			jTextArea = new JTextArea();
			jTextArea.setAutoscrolls(false);
		}
		return jTextArea;
	}

	public static DebugFrame theOnly() {
		if (df == null) df = new DebugFrame();
		return df;
	}

//	private static FileOutputStream fos; //  @jve:decl-index=0:
//
//	static {
//		if (MonitorModel.DEBUG) {
//			try {
//				fos = new FileOutputStream(Path.LOGFILE, false);
//				fos.write(("DebugMode ON" + System.getProperty("line.separator")).getBytes());
//				fos = new FileOutputStream(Path.LOGFILE, true);
//
//			} catch (FileNotFoundException ex) {
//				ex.printStackTrace();
//			} catch (IOException ex) {
//				ex.printStackTrace();
//			}
//		}
//	}

	public static void append(Object s) {
		if (MonitorModel.DEBUG) {
//			try {
//				fos.write((s.toString() + System.getProperty("line.separator")).getBytes());
//			} catch (IOException ex) {
//				ex.printStackTrace();
//			}
			theOnly().getjTextArea().append(s.toString() + System.getProperty("line.separator"));
			theOnly().getjTextArea().selectAll();
			int x = theOnly().getjTextArea().getSelectionEnd();
			theOnly().getjTextArea().select(x, x);
		}
	}


	private JScrollPane getJScrollPane() {
		if (jScrollPane == null) {
			jScrollPane = new JScrollPane();
			jScrollPane.setViewportView(getjTextArea()); // Generated

		}
		return jScrollPane;
	}

//	public static void main(String[] a) {
//		DebugFrame.append("ssdada");
//		DebugFrame.append("ssdada");
//		DebugFrame.append("ssdada");
//		DebugFrame.append("ssdada");
//		DebugFrame.append("ssdada");
//		DebugFrame.append("ssdada");
//		DebugFrame.append("ssdada");
//		DebugFrame.append("ssdada");
//		DebugFrame.append("ssdada");
//		DebugFrame.append("ssdada");
//		DebugFrame.append("ssdada");
//		DebugFrame.append("ssdada");
//		DebugFrame.append("ssdada");
//		DebugFrame.append("ssdada");
//		DebugFrame.append("ssdada");
//		DebugFrame.append("ssdada");
//		DebugFrame.append("ssdada");
//		DebugFrame.append("ssdada");
//		DebugFrame.append("ssdada");
//		DebugFrame.append("ssdada");
//		DebugFrame.append("ssdada");
//		DebugFrame.append("ssdada");
//
//		DebugFrame.theOnly().setVisible(true);
//	}

} //  @jve:decl-index=0:visual-constraint="10,10"
