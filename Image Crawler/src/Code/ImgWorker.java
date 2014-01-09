package Code;

import java.util.concurrent.Callable;

class ImgWorker implements Callable<Object> {
	private String myKeyword;
	private int myCount, myWidth, myHeight;
	private ImgCrawler getImg;

	public ImgWorker(String keyword, int count, int height, int width) {
		myCount = count;
		myWidth = width;
		myHeight = height;
		myKeyword = keyword;
		getImg = new ImgCrawler();
	}

	@Override
	public Object call() {
		int cnt = 0;
		boolean yes = false;
		while (cnt < 10 && yes == false) {
			try {
				cnt++;
				yes = getImg.loadImages(myKeyword, myCount, myWidth, myHeight);
			} catch (Exception e) {

				e.printStackTrace();
				return false;
			}

		}
		return yes;
	}

}
