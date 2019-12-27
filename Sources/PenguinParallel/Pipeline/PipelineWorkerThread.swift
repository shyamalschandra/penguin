import Foundation

class PipelineWorkerThread: Thread {
    static var startedThreadCount: Int32 = 0
    static var runningThreadCount: Int32 = 0

    public init(name: String) {
        super.init()
        self.name = name
    }

    /// This function must be overridden!
    func body() {
        preconditionFailure("No body in thread \(name!).")
    }

    override final func main() {
        OSAtomicIncrement32(&PipelineWorkerThread.startedThreadCount)
        OSAtomicIncrement32(&PipelineWorkerThread.runningThreadCount)
        condition.lock()
        state = .started
        condition.broadcast()
        condition.unlock()

        // Do the work
        body()

        OSAtomicDecrement32(&PipelineWorkerThread.runningThreadCount)
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
        let running = OSAtomicAdd32(0, &PipelineWorkerThread.runningThreadCount)  // Use an atomic read to prevent a race condition.
        return running == 0
    }
}
