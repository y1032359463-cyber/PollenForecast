import localUnitTest from './LocalUnit.test';
import cityUtilsTest from './CityUtils.test';
import qweatherDataSourceAdapterTest from './QweatherDataSourceAdapter.test';

export default function testsuite() {
  localUnitTest();
  cityUtilsTest();
  qweatherDataSourceAdapterTest();
}