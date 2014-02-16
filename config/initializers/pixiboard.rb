# config file for pixi-specific api keys
PIXI_KEYS = YAML::load_file("#{Rails.root}/config/pixi_keys.yml")[Rails.env]
PIXI_FEE = PIXI_KEYS['pixi']['fee']
PIXI_PERCENT = PIXI_KEYS['pixi']['percent']
PIXI_TXN_PERCENT = PIXI_KEYS['pixi']['txn_percent']
PXB_TXN_PERCENT = PIXI_KEYS['pixi']['pxb_txn_percent']
PIXI_BASE_PRICE = PIXI_KEYS['pixi']['base_price']
PIXI_PREMIUM_PRICE = PIXI_KEYS['pixi']['premium_price']
PIXI_DAYS = PIXI_KEYS['pixi']['days']
MIN_TXN_AMT = PIXI_KEYS['pixi']['min_txn_amt']
MAX_PIXI_AMT = PIXI_KEYS['pixi']['max_pixi_amt']
MAX_INV_QTY = PIXI_KEYS['pixi']['max_inv_qty']
PAYMENT_API = PIXI_KEYS['pixi']['payment_api']
CREDIT_CARD_API = PIXI_KEYS['pixi']['credit_card_api']
PIXIBOARD_INFO = PIXI_KEYS['pixi']['company_info']
PIXI_WEB_SITE = PIXI_KEYS['pixi']['host_address']
