import Foundation

class PipelineWorkerThread: Thread {
    static var startedThreadCount: Int32 = 0
    static var runningThreadCount: Int32 = 0
    static var lock = NSLock()

    public init(name: String) {
        super.init()
        self.name = name
    }

    /// This function must be overridden!
    func body() {
        preconditionFailure("No body in thread \(name!).")
    }

    override final func main() {
        PipelineWorkerThread.lock.lock()
        PipelineWorkerThread.startedThreadCount += 1
        PipelineWorkerThread.runningThreadCount += 1
        PipelineWorkerThread.lock.unlock()

        condition.lock()
        state = .started
        condition.broadcast()
        condition.unlock()

        // Do the work
        body()

        PipelineWorkerThread.lock.lock()
        PipelineWorkerThread.runningThreadCount -= 1
        PipelineWorkerThread.lock.unlock()
        assert(isFinished == false, "isFinished is not false??? \(self)")

        condition.lock()
        defer { condition.unlock() }
        state = .finished
        condition.broadcast()  // Wake up everyone who has tried to join against this thread.
    }

    /// Blocks until the worker thread has guaranteed to have started.
    func waitUntilStarted() {
        condition.lock()
        defer { condition.unlock() }
        while state == .initialized {
            condition.wait()
        }
    }

    /// Blocks until the body has finished executing.
    func join() {
        condition.lock()
        defer { condition.unlock() }
        while state != .finished {
            condition.wait()
        }
    }

    enum State {
        case initialized
        case started
        case finished
    }
    private var state: State = .initialized
    private var condition = NSCondition()
}

public extension PipelineIterator {
    /// Determines if all worker threads started by Pipeline iterators process-wide have been stopped.
    ///
    /// This is used during testing to ensure there are no resource leaks.
    static func _allThreadsStopped() -> Bool {
        // print("Running thread count: \(PipelineWorkerThread.runningThreadCount); started: \(PipelineWorkerThread.startedThreadCount).")
        PipelineWorkerThread.lock.lock()
        defer { PipelineWorkerThread.lock.unlock() }
        return PipelineWorkerThread.runningThreadCount == 0
    }
}
