package Code;

import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import javax.imageio.ImageIO;
import javax.net.ssl.HttpsURLConnection;

import com.mortennobel.imagescaling.ResampleOp;


public class ImgCrawler {
	// URL for google Image search
	private String[] request;
	static final String USER_AGENT = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36";
	
	
	/**
	 * Will Read keywords from file 'config.txt' in working directory and use an
	 * Executorservice to simultaneously download images
	 * config.txt format: count width height numThreads keyword1 ... keywordN
	 * @param args
	 * @throws Exception
	 */
	public static void main(String[] args) throws Exception {
		FileInputStream input = new FileInputStream(Paths.get("config.txt")
				.toFile());
		byte[] fileData = new byte[input.available()];
		input.read(fileData);
		input.close();
		String[] inputFile = (new String(fileData, "UTF-8")).split(" ", 5);
		int count = new Integer(inputFile[0]);
		int width = new Integer(inputFile[1]);
		int height = new Integer(inputFile[2]);
		int numThreads = new Integer(inputFile[3]);
		String[] keywords = inputFile[4].split(" ");
		ExecutorService pool = Executors.newFixedThreadPool(numThreads);
		ArrayList<Callable<Object>> tasks = new ArrayList<Callable<Object>>();
		for (int i = 0; i < keywords.length; i++) {
			tasks.add(new ImgWorker(keywords[i], count, width, height));
		}
		pool.invokeAll(tasks);
		pool.awaitTermination(2, TimeUnit.HOURS);
		System.out.println("Job Done");

	}

	
	public ImgCrawler() {
		super();
		this.request = new String[2];
		// The URL for Google Image download.
		this.request[0] = "https://www.google.de/search?q=";
		this.request[1] = "&biw=1600&bih=798&tbm=isch&source=lnt&tbs=isz:lt,islt:4mp&sa=X&ei=ChbBUt7fLcbGkQWk3YGwDg&ved=0CCAQpwU";
	}

	
	/**
	 * Will download images from Google image search according to the parameters
	 * @param keyword  The keyword to be searched for
	 * @param count    Number of images to download
	 * @param width	   Width of output images
	 * @param height   Height of output images
	 * @return		   True if job was succesful, false otherwise
	 */
	public boolean loadImages(String keyword, int count, int width, int height) {
		File dir = Paths.get("images").resolve(Paths.get(keyword)).toFile();
		if (!dir.exists()) {
			System.out.println("Creating directory " + dir.getAbsolutePath());
			dir.mkdir();
		}

		String connection = request[0] + keyword + request[1];
		HttpsURLConnection con = (HttpsURLConnection) this.getConn(connection);
		StringBuffer response = null;
		try (BufferedReader in = new BufferedReader(new InputStreamReader(
				con.getInputStream()))) {
			String inputLine;
			response = new StringBuffer();
			while ((inputLine = in.readLine()) != null) {
				response.append(inputLine);
			}
		} catch (IOException e1) {
			return false;
		}

		String[] imgURLS = parseImageURL(response, width, height);

		for (int numImg = 0, numLinks = 0; numImg < count; numLinks++) {
			try {
				// get the next image
				HttpURLConnection imgCon = this.getConn(imgURLS[numLinks]);
				// continue in case of http error
				if (imgCon.getResponseCode() != 200)
					continue;
				// get Image type and create output file
				if ((imgCon.getContentType().split("/")[0].equals("img")
						|| imgCon.getContentType().split("/")[0]
								.equals("image")) && imgCon.getContentLength() > 0) {
					String imgType = imgCon.getContentType().split("/")[1];
					File output = dir
							.toPath()
							.toAbsolutePath()
							.resolve(
									Paths.get(keyword + (numImg + 1) + "."
											+ imgType)).toFile();
					System.out.println("Creating File " + output);
					output.createNewFile();
					// Write image to output file
					try (FileOutputStream outStream = new FileOutputStream(
							output)) {
						byte[] buf = new byte[imgCon.getContentLength()];
						int num = 0;
						int offSet = 0;
						// read the whole image into the buffer
						while ((num = imgCon.getInputStream().read(buf, offSet,
								buf.length - offSet)) != -1)
							offSet += num;
						outStream.write(buf, 0, offSet);
					}
					numImg += this.resizeImage(width, height, output, imgType) ? 1 : 0;
				}
			} catch (Exception e) {
				System.err.println(e.getMessage());
				e.printStackTrace();
			}
		}
		return true;
	}

	private boolean resizeImage(int width, int height, File img, String fileExtension) {

		BufferedImage image = null;
		int imgWidth, imgHeight;
		try {
			image = ImageIO.read(img);
			imgWidth = image.getWidth();
			imgHeight = image.getHeight();

			} catch (IOException e) {
			img.delete();
			return false;
		}
		
		if (imgHeight < height || imgWidth < width) {
			img.delete();
			return false;
		}
		 if (imgHeight == height && imgWidth == width) 
			 return true;
				// scale
		 		BufferedImage rescaledImg = null;
				if (imgWidth / width < imgHeight / height) {
					ResampleOp  resampleOp = new ResampleOp (width, (int)Math.ceil( imgHeight / (imgWidth / width)));
					rescaledImg = resampleOp.filter(image, null); 
				} 
				if (imgWidth / width >= imgHeight / height) {
					ResampleOp  resampleOp = new ResampleOp ((int)Math.ceil(imgWidth / ( imgHeight / height)), height);
			 		rescaledImg = resampleOp.filter(image, null); 
				}
				// crop
				// calculate new Dimensions
				imgWidth = rescaledImg.getWidth();
				imgHeight = rescaledImg.getHeight();
				int x = imgWidth > width ?(int) Math.floor( (imgWidth - width) / 2) : 0;
				 int y = imgHeight > height ? (int)Math.floor((imgHeight - height)/ 2) : 0;
				BufferedImage croppedImg;
				 croppedImg = rescaledImg.getSubimage(x, y, width, height);
				 try {
					ImageIO.write(croppedImg, fileExtension, img);
				} catch (IOException e) {
					img.delete();
					return false;
				}
				return true;	
	}

	private String[] parseImageURL(StringBuffer response, int width, int height) {
		String[] links = response.toString().split("<a href=\"");
		int count = 0;
		for (int i = 0; i < links.length; i++) {
			if (links[i].startsWith("http://www.google.de/imgres?")) {
				links[count] = links[i].split("imgurl=")[1].split("&amp;")[0];
				count++;
			}
		}
		return Arrays.copyOfRange(links, 0, count);
	}

	private HttpURLConnection getConn(String locator) {
		URL url;
		try {
			url = new URL(locator);
			HttpURLConnection con = (HttpURLConnection) url.openConnection();
			con.setRequestProperty("User-Agent", USER_AGENT);
			con.setRequestMethod("GET");
			return con;
		} catch (MalformedURLException e1) {
			System.err.println("Malformed URL: " + locator);
			System.err.println(e1.getMessage());
		} catch (IOException e) {
			System.err.println("Error opening URL: " + locator);
			System.err.println(e.getMessage());
		}

		return null;
	}

}
