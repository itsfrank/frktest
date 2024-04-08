export type Failure = {
    location: {
        file: string,
        line: string,
    },
    message: string,
}

export type Test = {
    name: string,
    fn: () -> nil,
    failed: boolean,
}

export type Suite = {
    name: string,
    fn: () -> nil,
    tests: { [number]: Test },
}

export type ExecCounts = {
    suites: number,
    tests: number,
}

export type ExecResult = {
    ran: number,
    passed: number,
    failed: number,
}

return {}
