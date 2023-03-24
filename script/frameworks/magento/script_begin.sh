## Standard Magento script init by WEBSTACKUP.
# Sourced by https://github.com/TurboLabIt/webstackup/blob/master/my-app-template/scripts/script_begin.sh

MAGENTO_DIR=${PROJECT_DIR}shop/
WEBROOT_DIR=${MAGENTO_DIR}pub/
MAGENTO_MODULE_DISABLE=" \
  Magento_AdminAdobeImsTwoFactorAuth \
  Magento_TwoFactorAuth Magento_Csp Mageplaza_Core Magento_LoginAsCustomerGraphQl Magento_LoginAsCustomerAssistance \
  Magento_StoreGraphQl Magento_CatalogRuleGraphQl Magento_CheckoutAgreementsGraphQl Magento_CmsUrlRewriteGraphQl \
  Magento_CompareListGraphQl Magento_DirectoryGraphQl Magento_DownloadableGraphQl \
  Magento_CustomerDownloadableGraphQl Magento_CatalogCustomerGraphQl Magento_BundleGraphQl Magento_GiftMessageGraphQl \
  Magento_CatalogCmsGraphQl Magento_GroupedProductGraphQl Magento_ConfigurableProductGraphQl Magento_InventoryInStorePickupGraphQl \
  Magento_InventoryInStorePickupQuoteGraphQl Magento_InventoryQuoteGraphQl Magento_CatalogInventoryGraphQl \
  Magento_NewsletterGraphQl Magento_PaymentGraphQl Magento_PaypalGraphQl Magento_ReCaptchaWebapiGraphQl \
  Magento_RelatedProductGraphQl Magento_ReviewGraphQl Magento_SalesGraphQl Magento_SendFriendGraphQl \
  Magento_InventoryGraphQl Magento_SwatchesGraphQl Magento_TaxGraphQl \
  Magento_ThemeGraphQl Magento_CatalogUrlRewriteGraphQl Magento_VaultGraphQl Magento_WeeeGraphQl \
  Magento_WishlistGraphQl PayPal_BraintreeGraphQl \
  Magento_CmsGraphQl Magento_CustomerGraphQl Magento_QuoteGraphQl Magento_CatalogGraphQl Magento_EavGraphQl \
  Magento_GraphQlCache Magento_GraphQl Magento_UrlRewriteGraphQl \
"
COMPOSER_JSON_FULLPATH=${MAGENTO_DIR}composer.json
COMPOSER_SKIP_DUMP_AUTOLOAD=0
MAGENTO_STATIC_CONTENT_DEPLOY_ADMIN="it_IT en_US"
