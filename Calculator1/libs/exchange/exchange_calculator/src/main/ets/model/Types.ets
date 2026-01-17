export interface ICurrencyData {
  /**
   *  银行中间价
   */
  bankConversionPri: string;

  /**
   * 币种名称
   */
  name: string;

  /**
   * 国家名
   */
  country: string
  /**
   * 国家旗帜
   */
  pic: Resource
  /**
   * 日期
   */
  date: string;

  /**
   * 时间
   */
  time: string;
}

@ObservedV2
export class AreaType {
  @Trace top: number = 0;
  @Trace bottom: number = 0;
}