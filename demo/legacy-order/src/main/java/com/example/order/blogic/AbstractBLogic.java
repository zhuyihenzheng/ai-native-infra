package com.example.order.blogic;

/**
 * 業務ロジック基底クラス。本システムの全 BLogic はこれを継承する（Service層は存在しない）。
 * 呼び出し側は execute() を使う。実装は doExecute() に業務処理を書く。
 * 実行時例外はここで捕捉し、システムエラー（msg.common.e999）として返す。
 */
public abstract class AbstractBLogic<P, R> {

    public BLogicResult<R> execute(P param) {
        try {
            return doExecute(param);
        } catch (RuntimeException e) {
            return BLogicResult.systemError("msg.common.e999", e);
        }
    }

    protected abstract BLogicResult<R> doExecute(P param);
}
