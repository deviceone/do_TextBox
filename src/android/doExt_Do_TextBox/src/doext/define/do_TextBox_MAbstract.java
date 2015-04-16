package doext.define;

import core.object.DoUIModule;
import core.object.DoProperty;
import core.object.DoProperty.PropertyDataType;


public abstract class do_TextBox_MAbstract extends DoUIModule{

	protected do_TextBox_MAbstract() throws Exception {
		super();
	}
	
	/**
	 * 初始化
	 */
	@Override
	public void onInit() throws Exception{
        super.onInit();
        //注册属性
		this.registProperty(new DoProperty("fontColor", PropertyDataType.String, "000000FF", false));
		this.registProperty(new DoProperty("fontSize", PropertyDataType.Number, "9", false));
		this.registProperty(new DoProperty("fontStyle", PropertyDataType.String, "normal", false));
		this.registProperty(new DoProperty("hint", PropertyDataType.String, "", true));
		this.registProperty(new DoProperty("maxLength", PropertyDataType.Number, "100", true));
		this.registProperty(new DoProperty("text", PropertyDataType.String, "", false));
	}
}