type Location = {
    file: string,
    line: string,
}

export type Failure = {
    location: Location,
    message: string,
}

export type TestError = {
    location: Location,
    strace: string,
    error: any,
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
